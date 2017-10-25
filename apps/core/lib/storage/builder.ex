defmodule Builder do
  @moduledoc """
  有顺序要求的 Json 格式，通个这个类来约束 Poison 序列化 Json 格式时候的顺序
  """
  defmacro defschema(module, fields) do
    quote do
      keys = unquote(fields) |> Macro.escape
      defmodule unquote(module) do
        @derive [Poison.Encoder]
        defstruct keys
      end
      defimpl Poison.Encoder, for: unquote module do
        @doc """
          Encode 部分参考 https://github.com/devinus/poison/blob/master/lib/poison/encoder.ex#L216
        """
        def spaces(indent) do
          :binary.copy(" ", indent)
        end

        def encode(map, option) do
          pretty = !!Keyword.get(option, :pretty)
          encode(map, pretty, [indent: Keyword.get(option, :indent, 2), offset: Keyword.get(option, :offset, 0)])
        end
        def encode(map, true, options) do
          indent = options[:indent]
          offset = options[:offset] + indent
          options = [indent: indent, offset: offset, pretty: true]
          data = Enum.reduce(unquote(fields) |> :lists.reverse, [], fn key, acc ->
            value = Map.fetch!(map, key)
            if value != nil do
              [",\n", spaces(offset), Poison.Encoder.BitString.encode("#{key}", options), ": ", Poison.Encoder.encode(value, options) | acc]
            else
              acc
            end
          end)
          ["{\n", tl(data), ?\n, spaces(offset - indent), ?}]
        end

        def encode(map, _, options) do
          data = Enum.reduce(unquote(fields) |> :lists.reverse, [], fn key, acc ->
            value = Map.fetch!(map, key)
            if value != nil do
              [",", Poison.Encoder.BitString.encode("#{key}", options), ": ", Poison.Encoder.encode(value, options) | acc]
            else
              acc
            end
          end)
          [?{, tl(data), ?}]
        end
      end
    end
  end
end