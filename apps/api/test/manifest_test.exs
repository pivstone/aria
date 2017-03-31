defmodule ManifestTest do
	use ExUnit.Case, async: true

	test "Manifest V2 convert V1" do
	  manifestV2 = File.read!("test/data/schemaV2.json")|> Poison.decode!
		manifestV1 = Poison.decode!(File.read!("test/data/schemaV1_no_sign.json"))
    result = Manifest.transform_v2_to_v1(manifestV2 ,"registry","latest")|> Poison.encode!(pretty: true)
    :ok = File.write("test/data/schemaV2_.json",result)
	end

	test "verfiy manifest v1" do
	  manifestV1 = File.read!("test/data/schemaV1.json")
	  Manifest.verify(manifestV1)
	end
end