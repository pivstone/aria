defmodule Storage.Driver do
  @moduledoc """
  Documentation for Storage.
  """

  @type path :: String.t

  @callback move(src :: String.t, dist :: String.t) :: :ok | {:error, posix :: String.t}


  @callback digest(path) :: String.t


  @callback blob_size(path) :: non_neg_integer

  @callback read(path) :: binary

  @callback stream(path) :: [binary]

  @callback list(path) :: [String.t]

  @callback list(path, keyword :: String.t) :: [String.t]

  @callback exist?(path) :: true | false

end
