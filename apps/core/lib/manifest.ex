defmodule Manifest do

	@moduledoc """
	Manifest的想改操作集合
	"""
	@empty_blob_digest "sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4"
  @history_fields ["author", "comment", "throwaway"]
  @default_alg "ES256"
  @named_curve :secp256r1
  @jwa %{ "alg" => @default_alg}

	@doc """
  将 v2_v2 版本的 Manifest 转化成 v2_v1 版本
  """
  def transform_v2_to_v1(manifest,name,reference) do
    config_digest = manifest["config"]["digest"]
    config_string = Storage.get_blob(name, config_digest)
    config_data = config_string|> Poison.decode!(as: %Manifest.DockerConfig{container_config: %Manifest.ContainerConfig{},history: [%Manifest.DockerConfigHistory{}]})
    data = %Manifest.V1Schema{
      schemaVersion: 1,
      name: name,
      tag: reference,
      architecture: config_data.architecture,
      history: [],
      fsLayers: [],
    }
    # 最后一层额外处理
    {last,layers} = List.pop_at(config_data.history, -1)
    {data, _, parent_id} =
      Enum.reduce(layers,{data,-1,""}, fn layer,{data,layer_count,parent_id} ->
        {"sha256:"<>blob_sum,layer_count} =
          if layer.empty_layer == true do
            {@empty_blob_digest,layer_count}
          else
            layer_count = layer_count + 1
            digest = Map.fetch!(manifest,"layers")
              |> Enum.at(layer_count)
              |> Map.fetch!("digest")
            {digest,layer_count}
          end
        fs_layers = [%Manifest.FsLayers{blobSum: blob_sum}| data.fsLayers]
        data = %{data | fsLayers: fs_layers}
        # 构建 v1Compatibility 内容
        # 计算 blobSum
        v1_id = :sha256
          |> :crypto.hash_init()
          |> :crypto.hash_update(blob_sum <> " " <> parent_id)
          |> :crypto.hash_final
          |> Base.encode16
          |> String.downcase
        v1_layers = %Manifest.V1Compatibility{id: v1_id, created: layer.created, container_config: layer.created_by}
        v1_layers = parent_id != "" && %{v1_layers| parent: parent_id} || v1_layers
        v1_layers =
          Enum.reduce(@history_fields,v1_layers,fn(k,v1_layers) ->
            Map.has_key?(layer, k) && %{v1_layers| k: layer[k]} || v1_layers
           end)
        parent_id = v1_id
        v1_com = %Manifest.V1History{v1Compatibility: Poison.encode!(v1_layers)}
        history = [v1_com | data.history]
        data = %{data | history: history}
        {data, layer_count, parent_id}
      end)
    # 处理最后一层,最后一层可能会有兼容性问题
    # 主要是 config_string 的格式不明朗
    last_layer = config_data|> Map.from_struct
    "sha256:"<> blob_sum = Map.fetch!(manifest,"layers")
    |> Enum.at(0)
    |> Map.fetch!("digest")
    v1_id = :crypto.hash_init(:sha256)
    |> :crypto.hash_update(blob_sum <> " " <> parent_id <> " " <> to_string(config_string))
    |> :crypto.hash_final
    |> Base.encode16
    |> String.downcase
    last_layer = %{struct(Manifest.V1Compatibility,last_layer)|id: v1_id, parent: parent_id,throwaway: !!last.empty_layer}
    v1_com = %Manifest.V1History{v1Compatibility: Poison.encode!(last_layer)}
    history = [v1_com |data.history]
    %{data| history: history}
    sign(data)
  end

  @doc"""
  Manifest V2 v1 的签名
  """
  def sign(manifest) do
    {<<4,x::binary-size(32),y::binary-size(32)>> ,priv} = :crypto.generate_key(:ecdh,:secp256r1)
    payload  = Poison.encode!(manifest,pretty: true)
    formatlength = String.length(payload)-2
    tail = String.slice(payload,formatlength..-1)|> Base.url_encode64
    time = "2017-04-01T03:31:04Z"
    protected = @jwa
    |> Map.merge(%{"formatLength" => formatlength ,"formatTail" => tail,"time"=>time})
    |> Poison.encode!
    |> Base.url_encode64(padding: false)

    payload_encode = payload
    |> Base.url_encode64(padding: false)

    signed_encode  = :ecdsa
      |>:crypto.sign(:sha256,protected<>"."<>payload_encode,[priv,@named_curve])
      |> :sign.decode
      |> Base.url_encode64(padding: false)
    jwk_map = %{"x"=>x|>Base.url_encode64(padding: false),"y" => y|>Base.url_encode64(padding: false),"kty"=> "EC","crv"=> "P-256","kid"=> "5BMU:PCVF:5Z3G:LQKI:TJRU:XMVZ:PEDH:AMUS:YIPH:B5QV:XUEA:M6AO"}
    %{manifest| signatures: [%{"signature"=> signed_encode,"protected" => protected, "payload" => payload_encode,"header"=>%{"jwk" => jwk_map,"alg"=>"ES256"}}]}
  end

  @doc """
  校验 Manifest 的签名
  """
  def verify(plaintext) do
    manifest = Poison.decode!(plaintext,as: %Manifest.V1Schema{fsLayers: [%Manifest.FsLayers{}],history: [%Manifest.V1History{}]})
    signatures = manifest.signatures
    for signature <- signatures do
      header = Map.fetch!(signature,"header")
      protected =  signature
      |> Map.fetch!("protected")
      protected_header = protected
      |> Base.url_decode64!(padding: false)
      |> Poison.decode!
      payload = get_payload(protected_header,plaintext)
      jwk = get_verify_key(header)
      verify(jwk,%{"payload"=>payload,"signature"=>Map.fetch!(signature,"signature"),"protected"=>protected})
    end
  end

  defp get_payload(protected_data, plaintext) do
    format_len = Map.fetch!(protected_data,"formatLength")
    tail = protected_data
      |> Map.fetch!("formatTail")
      |> Base.url_decode64!(padding: false)
    String.slice(plaintext,0..format_len-1) <> tail
    |> Base.url_encode64(padding: false)
  end

  defp get_verify_key(header) do
    x = get_in(header,["jwk","x"])
    y = get_in(header,["jwk","y"])
    <<4>><>Base.url_decode64!(x,padding: false) <> Base.url_decode64!(y,padding: false)
  end


  defp verify(key, %{"payload" => payload, "signature" => encoded_signature, "protected" => protected}) do
    sig = encoded_signature
      |>  Base.url_decode64!(padding: false)
      |> :sign.encode
    msg = protected<>"."<>payload
  	:crypto.verify(:ecdsa,:sha256,msg,sig,[key,@named_curve])
  end

  def save(manifest, name, reference) do
    manifest_digest = Storage.save_manifest(name,manifest)
    current_tag_path = Storage.PathSpec.get_tag_current_path(name, reference)
    Storage.link(manifest_digest, current_tag_path)
    tag_index_path = Storage.PathSpec.get_tag_index_path(name, reference, manifest_digest)
    Storage.link(manifest_digest, tag_index_path)

    # Save reference
    reference_path = Storage.PathSpec.get_reference_path(name, manifest_digest)
    Storage.link(manifest_digest, reference_path)

    for layer <- get_layers(manifest) do
      layer_path = Storage.PathSpec.get_layer_path(name, layer)
      Storage.link(layer, layer_path)
    end
  end


  defp get_layers(manifest) do
    data = Poison.decode!(manifest)
    case Map.get(data,"schemaVersion") do
      1 -> for layer <- Map.get(data,"fsLayers"),do: Map.get(layer,"blobSum")
      2 -> for layer <- Map.get(data,"layers"),do: Map.get(layer,"digest")
    end
  end
end