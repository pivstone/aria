defmodule Api.BlobControllerTest do
  use Api.ConnCase


  test "PUT blob upload url resolve", %{conn: conn} do
    name = "test/test"
    uuid = "1234-123140123-1234-1231"
    conn = put conn, "/v2/#{name}/blobs/#{uuid}"
    assert json_response(conn, 200) == %{}
  end

  test "DELETE blob  url resolve", %{conn: conn} do
    name = "test/test"
    uuid = "1234-123140123-1234-1231"
    conn = delete conn, "/v2/#{name}/blobs/#{uuid}"
    assert json_response(conn, 200) == %{}
  end

  test "POST blob  url resolve", %{conn: conn} do
    name = "test/test"
    uuid = "1234-123140123-1234-1231"
    conn = post conn, "/v2/#{name}/blobs/#{uuid}"
    assert json_response(conn, 200) == %{}
  end

  test "GET blob  url resolve", %{conn: conn} do
    name = "test/test"
    uuid = "1234-123140123-1234-1231"
    conn = get conn, "/v2/#{name}/blobs/#{uuid}"
    assert json_response(conn, 200) == %{}
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

end
