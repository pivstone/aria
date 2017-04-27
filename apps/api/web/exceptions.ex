defimpl Plug.Exception, for: Storage.Exceptions.NotFoundError do
  def status(_exception), do: 404
end
