# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# By default, the umbrella project as well as each child
# application will require this configuration file, ensuring
# they all use the same configuration. While one could
# configure all applications here, we prefer to delegate
# back to each application for organization purposes.
import_config "../apps/*/config/config.exs"

# Sample configuration (overrides the imported configuration above):
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]

# Configures Elixir's Logger
config :logger, :console,
       format: "$time $metadata[$level] $message\n",
       metadata: [:request_id]


config :core, Storage.PathSpec,
	data_dir: System.cwd <>"/data"

config :core, Storage,
	driver: Storage.FileDriver


config :dashboard, Dashboard.Repo,
  registry_host: "reg.example.com"

config :accelerator, Accelerator.DockerUrl,
       upstream: "https://hub.c.163.com/v2/"
import_config "#{Mix.env}.exs"