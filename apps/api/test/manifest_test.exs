defmodule ManifestTest do
	use ExUnit.Case, async: true

	test "Manifest V2 convert V1" do
	  manifestV2 = File.read!("test/data/schemaV2.json")|> Poison.decode!
    result = Manifest.transform_v2_to_v1(manifestV2 ,"registry","latest")|> Poison.encode!(pretty: true)
    :ok = File.write("test/data/schemaV2_.json",result)

    assert Manifest.verify(File.read!("test/data/schemaV2_.json")) == [true]

	end

	test "Manifest V1 verify" do
    assert Manifest.verify(File.read!("test/data/schemaV1.json")) == [true]
  end
end