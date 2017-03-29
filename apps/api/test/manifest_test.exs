defmodule ManifestTest do
	use ExUnit.Case, async: true

	test "Manifest V2 convert V1" do
	  manifestV2 = File.read!("test/data/schemaV2.json")|> Poison.decode!
		manifestV1 = File.read!("test/data/schemaV1.json")|> Poison.decode!
		manifestV1 = Map.delete(manifestV1,"signatures")
    result = Manifest.transform_v2_to_v1(manifestV2 ,"registry","latest")

    assert manifestV1 == result
	end
end