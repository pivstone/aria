defmodule Manifest do
	@moduledoc """
	Manifest的想改操作集合
	"""
  defmodule V1Schema do
    @derive [Poison.Encoder]
    defstruct [:schemaVersion,
              :name,
              :tag,
              :architecture,
              :history,
              :fsLayers]
    defimpl Poison.Encoder, for: V1Schema do
      def encode(%{schemaVersion: schemaVersion, name: name, tag: tag,architecture: architecture, fsLayers: fsLayers, history: history}, options) do
        """
        {
           "schemaVersion:#{schemaVersion},
           "name":#{name}",
           "tag":#{tag},
           "architecture":#{architecture},
           "fsLayers":#{Poison.Encoder.encode(fsLayers, [pretty: true,intent: 4,offset: 4])},
           "history":#{Poison.Encoder.encode(history, [pretty: true,intent: 4,offset: 4])}
        }
        """
      end
    end
  end


	@empty_blob_digest "sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4"
  def transform_v2_to_v1(manifest,name,reference) do
    config_digest = manifest["config"]["digest"]
    IO.puts config_digest
    config_data = Storage.get_blob(name, config_digest)|> Poison.decode!
    data = %V1Schema{
      schemaVersion: 1,
      name: name,
      tag: reference,
      architecture: config_data["architecture"],
      history: [],
      fsLayers: [],
    }
    layer_count = 0
    parent_id = ""

    data =
      Enum.reduce(config_data["history"],data, fn layer,data ->
        # 计算 blob
        h = :crypto.hash_init(:sha256)
        blob_sum =
          if Map.has_key?(layer,"empty_layer") do
               @empty_blob_digest
          else
              layer_count = layer_count + 1
              Map.fetch!(manifest,"layers")
              |> Enum.at(layer_count)
              |> Map.fetch!("digest")
          end
        data = Map.put(data, :fsLayers, Map.fetch!(data,:fsLayers) ++[:blobSum, blob_sum])
        # 构建 v1Compatibility 内容
        :crypto.hash_update(h,blob_sum <> "  " <> parent_id)
        v1_id = :crypto.hash_final(h) |> Base.encode16 |> String.downcase
        v1_layers = %{"id" => v1_id, "created" => layer["created"], "container_config" => layer["created_by"]}
        v1_layers =
          if parent_id != "" do
            Map.put(v1_layers,"parent", parent_id)
          else
            v1_layers
        end
        v1_layers =
         for k <- ["author", "comment", "throwaway"] do
              if Map.has_key?(layer, k)do
                  Map.put(v1_layers,k,layer[k])
              else
                v1_layers
              end
          end
        parent_id = v1_id
        history = [%{:v1Compatibility => v1_layers}|Map.fetch!(data,:history)]
        data = Map.put(data, :history, history)
        data
      end)
    data = Map.put(data ,:history,Map.fetch!(data,:history)|>Enum.reverse())
    #crypto.jws_sign(data)
  end

end