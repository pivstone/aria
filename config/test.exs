use Mix.Config

config :storage, Storage.PathSepc,
	data_dir: Path.absname("./apps/storage/test/data")