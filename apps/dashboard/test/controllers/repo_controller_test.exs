defmodule Dashboard.RepoControllerTest do
  use Dashboard.ConnCase, async: true

  setup_all do
    :dets.delete_all_objects(:meta)
    Dashboard.Repo.insert("exmaple/registry", "latest")
    Dashboard.Repo.insert("lib/registry", "latest")
    Dashboard.Repo.insert("example/registry", "latest")
  end

  test "get repo list", %{conn: conn} do
    conn = get conn, "/images"
    assert json_response(conn, 200) == ["exmaple/registry", "lib/registry", "example/registry"]
  end


  test "retrieve repo info via name", %{conn: conn} do
    name = "example/registry"
    conn = get conn, "/images/#{URI.encode_www_form(name)}"
    assert json_response(conn, 200)["name"] == name
  end

  test "retrieve repo manifest config via name & references", %{conn: conn} do
    name = "test/test"
    reference = "latest"
    conn = get conn, "/images/manifest", %{"name" => name, "reference" => reference}
    assert json_response(conn, 200)["Env"] != nil
  end
end