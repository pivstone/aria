defmodule Accelerator.HttpTest do
  use ExUnit.Case, async: true

  test "the get" do
    assert {:ok, %Response{code: 401}} = Accelerator.Http.request(:get, "https://registry-1.docker.io/v2/")
  end
end
