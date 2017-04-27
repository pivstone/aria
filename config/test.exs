use Mix.Config

config :core, Storage.PathSpec,
	data_dir: Path.absname("./_tmp")

config :plug,
	validate_header_keys_during_test: false