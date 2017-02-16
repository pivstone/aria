defmodule Api.ManifestControllerTest do
  use Api.ConnCase


  test "GET manifests fetch url resolve", %{conn: conn} do
    name = "test/test"
    ref = "1-dev"
    conn = get conn, "/v2/#{name}/manifests/#{ref}"
    assert json_response(conn, 200) == %{"name" => name, "digest" => "", "tag" => ref}
  end
end
