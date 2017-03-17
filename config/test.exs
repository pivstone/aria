use Mix.Config

config :storage, Storage.PathSepc,
	data_dir: Path.absname("./_tmp")