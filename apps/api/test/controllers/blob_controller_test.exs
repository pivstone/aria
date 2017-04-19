defmodule Api.BlobControllerTest do
  use Api.ConnCase

  test "PUT blob upload url resolve", %{conn: conn} do
    name = "test/test"
    uuid = "1234-123140123-1234-1231"
    digest = "sha256:9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"
    conn = put_req_header(conn,"content-type", "application/octet-stream")
    |> put("/v2/#{name}/blobs/uploads/#{uuid}",[digest: digest])
    assert response(conn, 204)
  end

  test "DELETE blob  url resolve", %{conn: conn} do
    name = "test/test"
    digest = "sha256:046e44ee6057f1264d00b0c54adcff2f2c44d30a29b50dfef928776f7aa45cc8"
    assert_raise Api.DockerError,fn ->
      conn = delete conn, "/v2/#{name}/blobs/#{digest}"
      response(conn, 405)
    end
  end

  test "POST blob uploads url resolve", %{conn: conn} do
    name = "test/test"
    uuid = "1234-123140123-1234-1231"
    conn = post conn, "/v2/#{name}/blobs/uploads/#{uuid}"
    assert response(conn, 202)
  end

  test "POST  init blob  url resolve", %{conn: conn} do
    name = "test/test"
    conn = post conn, "/v2/#{name}/blobs/uploads/"
    assert response(conn, 202)
  end

  test "GET blob  url resolve", %{conn: conn} do
    name = "test/test"
    digest = "sha256:046e44ee6057f1264d00b0c54adcff2f2c44d30a29b50dfef928776f7aa45cc8"
    conn = get conn, "/v2/#{name}/blobs/#{digest}"
    assert response(conn, 200) == "test"
  end

  test "HEAD blob  url resolve", %{conn: conn} do
    name = "test/test"
    digest = "sha256:046e44ee6057f1264d00b0c54adcff2f2c44d30a29b50dfef928776f7aa45cc8"
    conn = head conn, "/v2/#{name}/blobs/#{digest}"
    assert response(conn, 200)
  end


  test "PATCH blob  url ", %{conn: conn} do
    name = "test/test"
    uuid = "1234-123140123-1234-0000"
    conn = put_req_header(conn,"content-type", "application/octet-stream")
    |> patch("/v2/#{name}/blobs/uploads/#{uuid}","test123")
    assert response(conn, 202)
  end

  test "PATCH blob  url resolve resolve without content-type", %{conn: conn} do
    name = "test/test"
    uuid = "1234-123140123-1234-0000"
    conn = put_req_header(conn,"content-type", "")
    |> patch("/v2/#{name}/blobs/uploads/#{uuid}","test123")
    assert response(conn, 202)
  end

  test "PUT blob upload invalid url resolve", %{conn: conn} do
    name = "Test/test"
    uuid = "1@234-1231"
    conn = put conn, "/v2/#{name}/blobs/#{uuid}"
    assert response(conn, 404)
  end

  test "DELETE blob  invalid url resolve", %{conn: conn} do
    name = "Test/test"
    uuid = "1@234-1231"
    conn = delete conn, "/v2/#{name}/blobs/#{uuid}"
    assert response(conn, 404)
  end

  test "POST blob  invalid url resolve", %{conn: conn} do
    name = "Test/test"
    uuid = "1@234-1231"
    conn = post conn, "/v2/#{name}/blobs/#{uuid}"
    assert response(conn, 404)
  end

  test "GET blob  invalid url resolve", %{conn: conn} do
    name = "Test/test"
    uuid = "1@234-1231"
    conn = get conn, "/v2/#{name}/blobs/#{uuid}"
    assert response(conn, 404)
  end

  test "HEAD blob  invalid url resolve", %{conn: conn} do
    name = "Test/test"
    uuid = "1@234-1231"
    conn = head conn, "/v2/#{name}/blobs/#{uuid}"
    assert response(conn, 404)
  end

  test "PATCH blob  invalid url resolve", %{conn: conn} do
    name = "Test/test"
    uuid = "1@234-1231"
    conn = patch conn, "/v2/#{name}/blobs/#{uuid}"
    assert response(conn, 404)
  end
end
