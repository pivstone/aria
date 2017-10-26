defmodule StorageTest do
  use ExUnit.Case, async: false
  doctest Storage, except: [repositories: 1]

  test "untag 1.0.1" do
    assert Storage.tags("untag") == ["latest", "1.0.1"]
    assert Storage.untag("untag", "1.0.1") == {
             :ok,
             [
               "#{Storage.PathSpec.data_dir()}/untag/_manifests/tags/1.0.1",
               "#{Storage.PathSpec.data_dir()}/untag/_manifests/tags/1.0.1/.keep"
             ]
           }
    assert Storage.tags("untag") == ["latest"]
  end

end
