defmodule Api.BlobUploadControllerTest do
  use Api.ConnCase

  test "PUT blob upload url resolve", %{conn: conn} do
    name = "test/test"
    uuid = "1234-123140123-1234-1231"
    digest = "sha256:9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"
    conn = put_req_header(conn,"content-type", "application/octet-stream")
    |> put("/v2/#{name}/blobs/uploads/#{uuid}",[digest: digest])
    assert response(conn, 204)
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


  test "PATCH blob  url ", %{conn: conn} do
    name = "test/test"
    uuid = "1234-123140123-1234-0000"
    conn = put_req_header(conn,"content-type", "application/octet-stream")
    |> patch("/v2/#{name}/blobs/uploads/#{uuid}","test123")
    assert response(conn, 202)
  end

  test "PATCH blob  url II", %{conn: conn} do
    name = "test/test"
    uuid = "a234-123140123-1234-0000"
    conn = put_req_header(conn,"content-type", "application/octet-stream")
    |> patch("/v2/#{name}/blobs/uploads/#{uuid}","test123")
    assert response(conn, 202)
  end

  test "PATCH blob  url resolve resolve without content-type", %{conn: conn} do
    name = "test/test"
    uuid = "1234-123140123-1234-0000"
    conn = put_req_header(conn,"content-type", "")
    |> put_req_header("transfer-encoding", "chunked")
    |> patch("/v2/#{name}/blobs/uploads/#{uuid}","test123")
    assert response(conn, 202)
  end

end
