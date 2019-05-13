use Mix.Config

config :core, Storage.PathSpec, data_dir: System.cwd() <> "/data"

config :dashboard, Dashboard.Repo, registry_host: "reg.example.com"

config :accelerator, Accelerator.DockerUrl, upstream: "https://registry-1.docker.io/v2/"

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :server, Server.Endpoint,
  secret_key_base: "1Jg/8G80nlLdluGbE+4YiyrDmLquNqh+4jT3lvGopY779MkgnVrcltoOT3DysFGA"
