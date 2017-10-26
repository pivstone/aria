defmodule Api.ManifestControllerTest do
  use Api.ConnCase


  test "GET manifests fetch url resolve", %{conn: conn} do
    name = "test/test"
    ref = "latest"
    conn = put_req_header(conn,"accept", "application/vnd.docker.distribution.manifest.v1+prettyjws")
    conn = get conn, "/v2/#{name}/manifests/#{ref}"
    assert response(conn, 200)
  end


  test "GET v1 manifests", %{conn: conn} do
    name = "registry"
    ref = "latest"
    conn = put_req_header(conn,"accept", "application/vnd.docker.distribution.manifest.v1+prettyjws")
    conn = get conn, "/v2/#{name}/manifests/#{ref}"
    assert Manifest.verify(name, response(conn, 200)) == true
  end


  test "GET v2 manifests", %{conn: conn} do
    name = "registry"
    ref = "latest"
    conn = get conn, "/v2/#{name}/manifests/#{ref}"
    assert json_response(conn, 200)
  end

  test "PUT manifests fetch url resolve", %{conn: conn} do
    name = "test/test"
    ref = "latest"
    conn = put_req_header(conn, "content-type", "application/vnd.docker.distribution.manifest.v1+prettyjws")
    conn = put conn, "/v2/#{name}/manifests/#{ref}",File.read!("test/fixtures/schemaV1.json")
    assert json_response(conn, 200) == %{"name" => name, "reference" => ref}
  end

  test "DELETE manifests use tag name", %{conn: conn} do
    name = "test/test"
    ref = "1-dev"
    conn = delete conn, "/v2/#{name}/manifests/#{ref}"
    assert response(conn, 204)
  end

  test "DELETE manifests use digest", %{conn: conn} do
    name = "test/test"
    ref = "sha256:9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"
    assert_raise Storage.Exception, fn ->
      delete conn, "/v2/#{name}/manifests/#{ref}"
    end
  end

  test "HEAD manifests fetch url resolve", %{conn: conn} do
    name = "test/test"
    ref = "latest"
    conn = put_req_header(conn,"accept", "application/vnd.docker.distribution.manifest.v1+prettyjws")
    conn = head conn, "/v2/#{name}/manifests/#{ref}"
    assert response(conn, 200)
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

  test "DELETE manifests fetch invalid url resolve", %{conn: conn} do
    name = "Rest/test"
    ref = "1-dev"
    conn = delete conn, "/v2/#{name}/manifests/#{ref}"
   assert response(conn, 404)
  end

  test "HEAD manifests fetch invalid url resolve", %{conn: conn} do
    name = "Rest/test"
    ref = "1-dev"
    conn = head conn, "/v2/#{name}/manifests/#{ref}"
   assert response(conn, 404)
  end

end
