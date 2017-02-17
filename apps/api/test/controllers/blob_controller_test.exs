defmodule Api.BlobControllerTest do
  use Api.ConnCase


  test "PUT blob upload url resolve", %{conn: conn} do
    name = "test/test"
    uuid = "1234-123140123-1234-1231"
    conn = put conn, "/v2/#{name}/blobs/#{uuid}"
    assert json_response(conn, 200) == %{}
  end


  test "PUT blob upload invalid url resolve", %{conn: conn} do
    name = "Test/test"
    uuid = "1@234-1231"
    conn = put conn, "/v2/#{name}/blobs/#{uuid}"
    assert response(conn, 404)
  end
end
