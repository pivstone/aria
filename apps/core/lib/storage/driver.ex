defmodule Storage.Driver do
  @moduledoc """
  Documentation for Storage.
  """
  @type posix :: :file.posix()

  @type path :: String.t

  @callback move(src :: String.t, dist :: String.t) :: :ok | {:error, posix :: String.t}

  @callback digest(path) :: String.t

  @callback save(path, data :: binary) :: :ok | no_return

  @callback size(path) :: non_neg_integer

  @callback read(path) :: binary

  @callback stream(path) :: File.Stream.t()

  @callback list(path) :: [String.t]

  @callback list(path, keyword :: String.t) :: [String.t]

  @callback exists?(path) :: true | false

  @callback delete(path) :: {:ok, [binary]} | {:error, posix, binary}

end
