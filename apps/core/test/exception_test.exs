defmodule ExceptionTest do
  use ExUnit.Case, async: true

  test "Core.Exception.status(%ArgumentError{message: \"argument error\"})" do
    assert Core.Exception.status(%ArgumentError{message: "argument error"}) == 500
  end

  test "Core.Exception.headers(%ArgumentError{message: \"argument error\"})" do
    assert Core.Exception.headers(%ArgumentError{message: "argument error"}) == %{}
  end
  test "Core.Exception.body(%ArgumentError{message: \"argument error\"})" do
    try do
      raise ArgumentError
    rescue
       ex ->
       assert  Core.Exception.body(ex) == "server internal error"
    end
  end
end