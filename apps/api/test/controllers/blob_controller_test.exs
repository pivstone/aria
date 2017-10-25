defmodule Api.BlobControllerTest do
  use Api.ConnCase


  test "DELETE blob  url resolve", %{conn: conn} do
    name = "test/test"
    digest = "sha256:046e44ee6057f1264d00b0c54adcff2f2c44d30a29b50dfef928776f7aa45cc8"
    assert_raise Storage.Exception, fn ->
      conn = delete conn, "/v2/#{name}/blobs/#{digest}"
      response(conn, 405)
    end
  end

  test "GET blob  url resolve", %{conn: conn} do
    name = "test/test"
    digest = "sha256:046e44ee6057f1264d00b0c54adcff2f2c44d30a29b50dfef928776f7aa45cc8"
    conn = get conn, "/v2/#{name}/blobs/#{digest}"
    assert response(conn, 200) == "test"
  end

  test "HEAD blob  url resolve", %{conn: conn} do
    name = "registry"
    digest = "sha256:4ab866128436778ccad5876ffacf2db98d396ba0a2cec7069d30480b1dd09d7d"
    conn = head conn, "/v2/#{name}/blobs/#{digest}"
    assert response(conn, 200)
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

  test "GET blob  invalid url resolve II", %{conn: conn} do
    name = "test/test/../"
    uuid = "a12341231"
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
