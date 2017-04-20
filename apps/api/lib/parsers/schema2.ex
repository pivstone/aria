defmodule Api.Parsers.Schema2 do
	@moduledoc """
	Docker Chunked Upload Parse
	"""

	@behaviour Plug.Parsers
	def parse(conn, "application", "vnd.docker.distribution.manifest.v2+json", _headers, _opts) do
    {:ok, body, _} = Plug.Conn.read_body(conn)
    {:ok, %{"data" => body}, conn}
  end

  def parse(conn, type, subtype, _headers, _opts) do
    {:next, conn}
  end

end