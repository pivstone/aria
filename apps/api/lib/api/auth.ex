defprotocol Api.Auth do
  @moduledoc """
  权限检查切入点
  """
  @fallback_to_any true
  @doc """
  授权检查
  """
  def authenticate(conn)
end

defimpl Api.Auth, for: Any do
  @moduledoc """
  默认实现
  """
  def authenticate(conn), do: conn
end
