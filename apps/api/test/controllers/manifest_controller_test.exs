defmodule Api.ManifestControllerTest do
  use Api.ConnCase


  test "GET manifests fetch url resolve", %{conn: conn} do
    name = "test/test"
    ref = "1-dev"
    conn = get conn, "/v2/#{name}/manifests/#{ref}"
    assert json_response(conn, 200) == %{"name" => name, "digest" => "", "tag" => ref}
  end

  test "PUT manifests fetch url resolve", %{conn: conn} do
    name = "test/test"
    ref = "1-dev"
    conn = put conn, "/v2/#{name}/manifests/#{ref}"
    assert json_response(conn, 200) == %{"name" => name, "digest" => "", "tag" => ref}
  end

  test "GET manifests fetch invalid url resolve", %{conn: conn} do
    name = "Rest/test"
    ref = "1-dev"
    conn = get conn, "/v2/#{name}/manifests/#{ref}"
    assert response(conn, 404)
  end

  test "PUT manifests fetch invalid url resolve", %{conn: conn} do
    name = "Rest/test"
    ref = "1-dev"
    conn = put conn, "/v2/#{name}/manifests/#{ref}"
   assert response(conn, 404)
  end

end
