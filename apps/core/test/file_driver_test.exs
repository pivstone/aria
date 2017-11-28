defmodule FileDriverTest do
  use ExUnit.Case, async: true

  test "file move " do
    src = System.tmp_dir <> "_test1"
    dist = System.tmp_dir <> "_test2/data"

    File.mkdir(src)
    File.mkdir(System.tmp_dir <> "_test2")
    src = src <> "/data"
    File.write(src, "test")
    Storage.FileDriver.move(src, dist)
    assert File.exists?(src) == false
    assert File.exists?(dist) == true
  end
end
