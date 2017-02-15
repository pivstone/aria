defmodule Api.PageControllerTest do
  use Api.ConnCase

  test "GET /v2", %{conn: conn} do
    conn = get conn, "/v2"
    assert json_response(conn, 200) == %{}
  end
end
