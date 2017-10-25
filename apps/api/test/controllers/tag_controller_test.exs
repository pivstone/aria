defmodule Api.TagControllerTest do
  use Api.ConnCase

  test "GET image tag list url resolve", %{conn: conn} do
    name = "test/test"
    conn = get conn, "/v2/#{name}/tags/list"
    assert json_response(conn, 200) == %{"name" => name, "tags" => [ "latest"]}
  end

  test "GET image tag list use invalid url resolve", %{conn: conn} do
    name = "T.t@est..test"
    conn = get conn, "/v2/#{name}/tags/list"
    assert response(conn, 404)
  end

  test "GET image tag list use not exist image name", %{conn: conn} do
    name = "esttest"
    assert_raise Storage.Exception, fn ->
       get conn, "/v2/#{name}/tags/list"
    end
  end

end
