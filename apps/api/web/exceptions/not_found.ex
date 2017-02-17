defmodule Api.Exceptions.NotFound do
  defexception [:message, :plug_status]

  def exception(_) do
    %__MODULE__{message: "not found", plug_status: 404}
  end
end