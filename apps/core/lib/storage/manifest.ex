defmodule Manifest do
  @moduledoc """
  Manifest
  """

  alias Phoenix.PubSub
  require Logger

  @empty_blob_digest "sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4"
  @history_fields ["author", "comment", "throwaway"]
  @default_alg "ES256"
  @named_curve :secp256r1
  @jwa %{"alg" => @default_alg}
  @config_type "application/vnd.docker.container.image.v1+json"
  @layer_type  "application/vnd.docker.image.rootfs.diff.tar.gzip"

  @doc """
  Return docker image config
  """
  def config(name, reference) do
    manifest =
      name
      |> Storage.manifest(reference)
      |> Poison.decode!
    verison = version(manifest)
    config(name, manifest, verison)
  end

  def config(_name, manifest, 1) do
    manifest
      |> Map.fetch!("history")
      |> Enum.at(0)
      |> Map.fetch!("v1Compatibility")
      |> Poison.decode!
      |> Map.fetch!("config")
  end

  def config(name, manifest, 2) do
    config_digest = manifest["config"]["digest"]
    name
      |> Storage.blob(config_digest)
      |> Poison.decode!
      |> Map.fetch!("config")
  end
  def version(%{"schemaVersion" => 2} = _manifest),  do: 2
  def version(%{"schemaVersion" => 1} = _manifest),  do: 1
  def version(%{"schemaVersion" => _} = manifest)  do
    Logger.warn(fn -> "manifest #{inspect manifest} version error!" end)
    raise Storage.Exception,
      message: "manifest invalid",
      code: "MANIFEST_INVALID",
      plug_status: 400
  end
  def version(plaintext) when is_binary(plaintext) do
    plaintext
    |> Poison.decode!
    |> version
  end
  @doc """
  transform v2_v2 version Manifest to v2_v1 version
  """
  def transform_v2_to_v1(manifest, name, reference) when is_binary(manifest) do
    transform_v2_to_v1(Poison.decode!(manifest), name, reference)
  end
  def transform_v2_to_v1(%{} = manifest, name, reference) do
    config_digest = get_in manifest,["config","digest"]
    config_string = Storage.blob(name, config_digest)
    config_data = config_string |> Poison.decode!(as: %Manifest.DockerConfig{container_config: %Manifest.ContainerConfig{}, history: [%Manifest.DockerConfigHistory{}]})
    data = %Manifest.V1Schema{
      schemaVersion: 1,
      name: name,
      tag: reference,
      architecture: config_data.architecture,
      history: [],
      fsLayers: [],
    }
    # handle last layer image config
    {last, layers} = List.pop_at(config_data.history, -1)
    {data, _, parent_id} =
      Enum.reduce(layers, {data, -1, ""} , fn layer, {data, layer_count, parent_id} ->
        {blob_sum, layer_count} =
          if layer.empty_layer == true do
            {@empty_blob_digest, layer_count}
          else
            layer_count = layer_count + 1
            digest =
              manifest
              |> Map.fetch!("layers")
              |> Enum.at(layer_count)
              |> Map.fetch!("digest")
            {digest, layer_count}
          end
        fs_layers = [%Manifest.FsLayers{blobSum: blob_sum}| data.fsLayers]
        data = %{data | fsLayers: fs_layers}
        # build v1Compatibility value
        # calc blobSum
        v1_id = :sha256
          |> :crypto.hash_init()
          |> :crypto.hash_update(blob_sum <> " " <> parent_id)
          |> :crypto.hash_final
          |> Base.encode16
          |> String.downcase
        v1_layers = %Manifest.V1Compatibility{id: v1_id, created: layer.created, container_config: layer.created_by}
        v1_layers = parent_id != "" && %{v1_layers| parent: parent_id} || v1_layers
        v1_layers =
          Enum.reduce(@history_fields, v1_layers, fn(k, v1_layers) ->
            Map.has_key?(layer, k) && %{v1_layers| k: layer[k]} || v1_layers
           end)
        parent_id = v1_id
        v1_com = %Manifest.V1History{v1Compatibility: Poison.encode!(v1_layers)}
        history = [v1_com | data.history]
        data = %{data | history: history}
        {data, layer_count, parent_id}
      end)
    last_layer = config_data |> Map.from_struct
    blob_sum =
      manifest
      |> Map.fetch!("layers")
      |> Enum.at(0)
      |> Map.fetch!("digest")
    v1_id =
      :sha256
      |> :crypto.hash_init
      |> :crypto.hash_update(blob_sum <> " " <> parent_id <> " " <> to_string(config_string))
      |> :crypto.hash_final
      |> Base.encode16
      |> String.downcase
    last_layer = %{struct(Manifest.V1Compatibility, last_layer)|id: v1_id, parent: parent_id, throwaway: !!last.empty_layer}
    v1_com = %Manifest.V1History{v1Compatibility: Poison.encode!(last_layer)}
    history = [v1_com | data.history]
    data = %{data| history: history}
    sign(data)
  end

  @doc"""
  Manifest V2 v1 JWT sign
  """
  def sign(manifest) do
    {<<4, x::binary-size(32), y::binary-size(32)>>, priv} = :crypto.generate_key(:ecdh, :secp256r1)
    payload  = Poison.encode!(manifest, pretty: true)
    formatlength = String.length(payload) - 2
    tail =
      payload
      |> String.slice(formatlength..-1)
      |> Base.url_encode64
    time = "2017-04-01T03:31:04Z"
    protected = @jwa
      |> Map.merge(%{"formatLength" => formatlength , "formatTail" => tail, "time" => time})
      |> Poison.encode!
      |> Base.url_encode64(padding: false)

    payload_encode = payload
      |> Base.url_encode64(padding: false)

    signed_encode  = :ecdsa
      |> :crypto.sign(:sha256, protected <> "." <> payload_encode, [priv, @named_curve])
      |> :sign.decode
      |> Base.url_encode64(padding: false)
    jwk_map = %{"x" => x |> Base.url_encode64(padding: false), "y" => y |> Base.url_encode64(padding: false), "kty" => "EC", "crv" => "P-256", "kid" => "5BMU:PCVF:5Z3G:LQKI:TJRU:XMVZ:PEDH:AMUS:YIPH:B5QV:XUEA:M6AO"}
    %{manifest| signatures: [%{"signature"=> signed_encode, "protected" => protected, "payload" => payload_encode, "header" => %{"jwk" => jwk_map, "alg" => "ES256"}}]}
  end

  @doc """
  Verify Signature of Manifest
  """
  def verify(name, plaintext) do
    version = version(plaintext)
    verify(name, plaintext, version)
  end
  @doc """
  Verify of v1 Manifest signature
  """
  def verify(name, plaintext, 1) do
    manifest = Poison.decode!(plaintext, as: %Manifest.V1Schema{fsLayers: [%Manifest.FsLayers{}], history: [%Manifest.V1History{}]})
    for layer <- manifest.fsLayers do
      if layer.blobSum != @empty_blob_digest do
        Storage.verify(name, layer.blobSum)
      end
    end
    signatures = manifest.signatures
    result =
      for signature <- signatures do
        header = Map.fetch!(signature, "header")
        protected =  signature
        |> Map.fetch!("protected")
        protected_header = protected
        |> Base.url_decode64!(padding: false)
        |> Poison.decode!
        payload = payload(protected_header, plaintext)
        jwk = verify_key(header)
        verify_key(jwk, %{"payload" => payload, "signature" => Map.fetch!(signature, "signature"), "protected" => protected})
      end
    Enum.all?(result, fn(x) -> x end)
  end

  @doc """
  Verify of v2 Manifest signature
  """
  def verify(name, plaintext, 2) do
    manifest = Poison.decode!(plaintext)
    config =  Map.fetch!(manifest, "config")
    digest = Map.fetch!(config, "digest")
    media_type = Map.fetch!(config, "mediaType")
    Storage.verify(name, digest)
    if media_type != @config_type do
      Logger.warn(fn -> "manifest #{name} verify failed cause:config layer mediaType invalid" end)
      raise Storage.Exception,
        message: "mediaType invalid",
        code: "MANIFEST_INVALID",
        plug_status: 400
    end
    for layer <- manifest["layers"] do
      media_type = Map.fetch!(layer, "mediaType")
      if media_type != @layer_type do
        Logger.warn(fn -> "manifest #{name} verify failed cause:layer mediaType invalid" end)
        raise Storage.Exception,
          message: "mediaType invalid",
          code: "MANIFEST_INVALID",
          plug_status: 400
      end
      digest = Map.fetch!(layer, "digest")
      if digest != @empty_blob_digest do
        Storage.verify(name, digest)
      end
    end
    true
  end
  defp payload(protected_data, plaintext) do
    format_len = Map.fetch!(protected_data, "formatLength")
    tail = protected_data
      |> Map.fetch!("formatTail")
      |> Base.url_decode64!(padding: false)
    String.slice(plaintext, 0..format_len - 1) <> tail
    |> Base.url_encode64(padding: false)
  end

  defp verify_key(header) do
    x = get_in(header, ["jwk", "x"])
    y = get_in(header, ["jwk", "y"])
    <<4>> <> Base.url_decode64!(x, padding: false) <> Base.url_decode64!(y, padding: false)
  end


  defp verify_key(key, %{"payload" => payload, "signature" => encoded_signature, "protected" => protected}) do
    sig = encoded_signature
      |>  Base.url_decode64!(padding: false)
      |> :sign.encode
    msg = protected <> "." <> payload
  	:crypto.verify(:ecdsa, :sha256, msg, sig, [key, @named_curve])
  end

  def save(_manifest, nil, _reference), do: Logger.error fn -> "" end
  def save(manifest, name, reference) do
    manifest_digest = Storage.save_manifest(name, manifest)
    current_tag_path = Storage.PathSpec.tag_current_path(name, reference)
    Storage.link(manifest_digest, current_tag_path)
    tag_index_path = Storage.PathSpec.tag_index_path(name, reference, manifest_digest)
    Storage.link(manifest_digest, tag_index_path)

    # Save reference
    reference_path = Storage.PathSpec.reference_path(name, manifest_digest)
    Storage.link(manifest_digest, reference_path)
    # Broadcast manifest signal
    PubSub.broadcast_from Aria.PubSub, self(), "manifest", {:save_manifest, name, reference}
  end

end
