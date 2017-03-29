defmodule ManifestTest do
	use ExUnit.Case, async: true

	test "Manifest V2 convert V1" do
	  manifestV2 = File.read!("test/data/schemaV2.json")|> Poison.decode!
		manifestV1 = Poison.decode!(File.read!("test/data/schemaV1_no_sign.json"),keys: :atoms!)
    result = Manifest.transform_v2_to_v1(manifestV2 ,"registry","latest")|> Map.from_struct
    assert manifestV1 == result
	end
end