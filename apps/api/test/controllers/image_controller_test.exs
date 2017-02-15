defmodule Api.ImageControllerTest do
  use Api.ConnCase

  test "GET catalog url resolve", %{conn: conn} do
    conn = get conn, "/v2/_catalog"
    assert json_response(conn, 200) == %{"repositories" => []}
  end

  test "GET image tag list url resolve", %{conn: conn} do
    name = "test/test"
    conn = get conn, "/v2/#{name}/tags/list"
    assert json_response(conn, 200) == %{"name" => name, "tags" => []}
  end
end
