defmodule Storage do
  @moduledoc """
  Documentation for Storage.
  """
  @default_driver Storage.FileDriver
  def driver do
    Application.get_env(:storage, __MODULE__, [])[:driver]||@default_driver
  end

end
