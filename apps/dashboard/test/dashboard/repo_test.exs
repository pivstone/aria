defmodule Dashboard.RepoTest do
  use ExUnit.Case
  doctest Dashboard.Repo

  setup do
    :dets.delete_all_objects(:meta)
  end
end
