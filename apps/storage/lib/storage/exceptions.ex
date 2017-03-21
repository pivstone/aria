defmodule Storage.FileError do
  defexception [:message , :code, :detail ,:plug_status]
end
