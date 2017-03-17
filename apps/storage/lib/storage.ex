defmodule Storage do
  @moduledoc """
  Documentation for Storage.
  """
  @default_driver Storage.FileDriver
  def driver do
    Application.get_env(:storage, __MODULE__, [])[:driver]||@default_driver
  end

  defmodule FileNotFoundError do
    defexception [:message , :plug_status]

    def exception(_) do
      %__MODULE__{message: "not found", plug_status: 404}
    end
  end

end
