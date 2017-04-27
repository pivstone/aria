defmodule Api.ManifestControllerTest do
  use Api.ConnCase


  test "GET manifests fetch url resolve", %{conn: conn} do
    name = "test/test"
    ref = "latest"
    conn = put_req_header(conn,"content-type", "application/vnd.docker.distribution.manifest.v1+prettyjws")
    conn = get conn, "/v2/#{name}/manifests/#{ref}"
    assert json_response(conn, 200)
  end

  test "PUT manifests fetch url resolve", %{conn: conn} do
    name = "test/test"
    ref = "latest"
    conn = put_req_header(conn,"content-type", "application/vnd.docker.distribution.manifest.v1+prettyjws")
    conn = put conn, "/v2/#{name}/manifests/#{ref}",File.read!("test/data/schemaV1.json")
    assert json_response(conn, 200) == %{"name" => name, "reference" => ref}
  end

  test "DELETE manifests fetch url resolve", %{conn: conn} do
    name = "test/test"
    ref = "1-dev"
    conn = delete conn, "/v2/#{name}/manifests/#{ref}"
    assert json_response(conn, 200) == %{"name" => name, "digest" => "", "tag" => ref}
  end

  test "HEAD manifests fetch url resolve", %{conn: conn} do
    name = "test/test"
    ref = "latest"
    conn = put_req_header(conn,"content-type", "application/vnd.docker.distribution.manifest.v1+prettyjws")
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
