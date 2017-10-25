defmodule ExceptionTest do
  use ExUnit.Case, async: true

  test "Aria.Exception.status(%ArgumentError{message: \"argument error\"})" do
    assert Aria.Exception.status(%ArgumentError{message: "argument error"}) == 500
  end

  test "Aria.Exception.headers(%ArgumentError{message: \"argument error\"})" do
    assert Aria.Exception.headers(%ArgumentError{message: "argument error"}) == %{}
  end
  test "Aria.Exception.body(%ArgumentError{message: \"argument error\"})" do
    try do
      raise ArgumentError
    rescue
       ex ->
       assert  Aria.Exception.body(ex) == "argument error"
    end
  end
end