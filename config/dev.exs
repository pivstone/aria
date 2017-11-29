use Mix.Config


# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :server, Server.Endpoint,
       http: [port: 4200],
       debug_errors: true,
       code_reloader: true,
       check_origin: false




# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :core, Storage.PathSpec,
       data_dir: System.cwd <> "/data"

config :core, Storage,
       driver: Storage.FileDriver


config :dashboard, Dashboard.Repo,
       registry_host: "reg.example.com"

#config :accelerator, Accelerator.DockerUrl,
#       upstream: "https://registry-1.docker.io/v2/"

config :accelerator, Accelerator.DockerUrl,
       upstream: "https://hub.c.163.com/v2/"
