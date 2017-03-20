use Mix.Config

config :storage, Storage.PathSpec,
	data_dir: Path.absname("./_tmp")