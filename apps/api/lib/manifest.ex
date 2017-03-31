defmodule Manifest do

	@moduledoc """
	Manifest的想改操作集合
	"""
	@empty_blob_digest "sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4"
  @history_fields ["author", "comment", "throwaway"]
  @jwk JOSE.JWK.generate_key({:ec, "P-256"})
  @jwa %{ "alg" => "ES256" }
  @jwk_map @jwk |> JOSE.JWK.to_map|> elem(1)
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
        # 计算 blobSum
        h = :crypto.hash_init(:sha256)
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
        h = :crypto.hash_update(h,blob_sum <> " " <> parent_id)
        v1_id = :crypto.hash_final(h) |> Base.encode16 |> String.downcase
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
    {_, signed} = JOSE.JWS.sign(@jwk, Poison.encode!(manifest,pretty: true), @jwa)
    signed = signed
    |> Map.merge(%{header: %{jwk: @jwk_map} |> Map.merge(@jwa)})
    |> Map.delete("payload")
    %{manifest| signatures: [signed]}
  end

  @doc """
  校验 Manifest 的签名
  """
  def verify(plaintext) do
    manifest = Poison.decode!(plaintext,as: %Manifest.V1Schema{fsLayers: [%Manifest.FsLayers{}],history: [%Manifest.V1History{}]})
    signatures = manifest.signatures
    for signature <- signatures do
      header = Map.fetch!(signature,"header")
      protected_header =  Map.fetch!(signature,"protected")
      sign = Map.fetch!(signature,"signature")
      payload = get_payload(protected_header,plaintext)
      IO.puts payload
      vk = get_verify_key(header)
      #vk.verify(_decode(sign), payload)
    end
  end

  defp get_payload(protected_header,plaintext) do
    IO.puts protected_header |> Base.decode64!(case: :lower)
    protected_data = protected_header
      |> Base.decode16!
      |> to_string
      |> Poison.decode!
    format_len = Map.fetch!(protected_data,"formatLength")
    tail = protected_data
      |> Map.fetch!("formatTail")
      |> Base.decode64!
    String.slice(plaintext,0..format_len) <> tail
  end

  defp get_verify_key(header) do
    jwk = header
      |> Map.fetch!("jwk")
      |> JOSE.JWK.from
      |> elem(1)
  end
  
end