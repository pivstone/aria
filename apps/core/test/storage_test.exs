defmodule StorageTest do
  use ExUnit.Case, async: false
  doctest Storage

  test "untag 1.0.1" do
    assert Storage.get_tags("untag") == ["latest", "1.0.1"]
    assert Storage.untag("untag", "1.0.1") == {:ok, ["#{Storage.PathSpec.data_dir()}/untag/_manifests/tags/1.0.1"]}
    assert Storage.get_tags("untag") == ["latest"]
  end
  
end
