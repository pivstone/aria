defmodule Api.ImageControllerTest do
  use Api.ConnCase

  test "check is repo locked, when repo is unlocked?", %{conn: conn} do
    name = "test/test"
    conn = head conn, "/v2/#{name}/_lock"
    assert response(conn, 404)
  end


  test "locked repo", %{conn: conn} do
    name = "registry"
    conn = post conn, "/v2/#{name}/_lock"
    on_exit(self(), fn -> Storage.unlock(name)  end)
    assert response(conn, 202)
    assert Storage.locked?(name) == true
  end

  test "check is repo locked, when repo is locked?", %{conn: conn} do
    name = "registry"
    on_exit(self(), fn -> Storage.unlock(name)  end)
    Storage.lock(name)
    conn = head conn, "/v2/#{name}/_lock"
    assert response(conn, 200)
  end

  test "delete repo, when repo is locked", %{conn: conn} do
    name = "test/delete"
    Storage.lock(name)
    conn  = delete conn, "/v2/#{name}"
    assert response(conn, 202)
    assert Storage.exists?(name) == false
  end

end
