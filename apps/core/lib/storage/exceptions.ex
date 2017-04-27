defmodule Docker.Exception do
  defexception [:message , :code, :detail ,:plug_status]
end
