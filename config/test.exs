use Mix.Config

config :server, Server.Endpoint,
       http: [port: 4001],
       server: false,
       secret_key_base: "1ad12e21+dasd2"

# Print only warnings and errors during test
config :logger, level: :warn

config :core, Storage.PathSpec,
       data_dir: System.cwd <>"/_tmp"

config :core, Storage,
       driver: Storage.FileDriver


config :dashboard, Dashboard.Repo,
       registry_host: "reg.example.com"

config :accelerator, Accelerator.DockerUrl,
       upstream: "https://registry-1.docker.io/v2/"


config :plug,
	validate_header_keys_during_test: false