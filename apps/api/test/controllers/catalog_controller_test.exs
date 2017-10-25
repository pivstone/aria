defmodule Api.CatalogControllerTest do
  use Api.ConnCase

  test "GET catalog url resolve", %{conn: conn} do
    conn = get conn, "/_catalog"
    assert json_response(conn, 200) == %{"repositories" => ["test/test", "registry"]}
  end

end
