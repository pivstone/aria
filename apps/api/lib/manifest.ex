defmodule Manifest do

	@moduledoc """
	Manifest的想改操作集合
	"""
	@empty_blob_digest "sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4"

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
        v1_layers =
          if parent_id != "" do
            %{v1_layers| parent: parent_id}
          else
            v1_layers
          end
        v1_layers =
         for k <- ["author", "comment", "throwaway"] do
              if Map.has_key?(layer, k)do
                  %{v1_layers| k: layer[k]}
              else
                v1_layers
              end
          end
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
  end

  def sign() do
    {pub, priv} = :crypto.generate_key(:ecdh, :prime256v1)
  end
end