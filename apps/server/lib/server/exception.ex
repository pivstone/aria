defimpl Aria.Exception, for: Phoenix.Router.NoRouteError do
  def body(_exception), do: "not_found"
  def status(_exception), do: 404
  def headers(_), do: %{"content_type" => "plain/text"}
end