defmodule Dashboard.Tag do
  @moduledoc """
  Repo tag 信息
  """
  defstruct [:name, :updated_time]

  @doc ~S"""
  iex> name = "latest"
  iex> tag = Dashboard.Tag.new(name)
  iex> tag.name
  "latest"
  """
  def new(name) do
    %Dashboard.Tag{
      name: name,
      updated_time: :os.system_time(:milli_seconds),
    }
  end
end
