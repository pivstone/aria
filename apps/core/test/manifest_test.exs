defmodule ManifestTest do
  use ExUnit.Case, async: true

  test "Manifest V2 convert V1" do
    manifestV2 = File.read!("./test/fixtures/schemaV2.json")|> Poison.decode!
    data = Manifest.transform_v2_to_v1(manifestV2, "registry", "latest")
    result= Poison.encode!(data, pretty: true)
    :ok = File.write("test/fixtures/schemaV2_.json", result)
    assert Manifest.verify("registry", File.read!("./test/fixtures/schemaV2_.json")) == true
    assert Map.fetch!(data,:history)
        |> Enum.at(0)
        |> Map.fetch!(:v1Compatibility)
        |> Poison.decode!
        |> Map.fetch!("architecture")
        == "amd64"
  end
  test "Manifest V1 verify" do
    assert Manifest.verify("registry", File.read!("./test/fixtures/schemaV1.json")) == true
  end

  test "manifest save" do
    manifestV2 = File.read!("./test/fixtures/schemaV2.json")
    assert Manifest.save(manifestV2 , "registry", "latest") == :ok
  end

  test "manifest get config" do
    config = Manifest.config("test/test", "latest")
    assert Map.has_key?(config, "Cmd")
    assert Map.has_key?(config, "Env")
    assert Map.has_key?(config, "Volumes")
  end

  test "Manifest V2 verify" do
    assert Manifest.verify("registry", File.read!("./test/fixtures/schemaV2.json")) == true
  end
end