# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config



config :mime, :types, %{
  "application/vnd.docker.distribution.manifest.v1+prettyjws" => ["manifest.v1-prettyjws"],
  "application/vnd.docker.distribution.manifest.v2+json" => ["manifest.v2-json"],
  "application/vnd.docker.distribution.manifest.list.v2+json" => ["manifest.v2.list-json"]
}

config :accelerator, Accelerator.DockerUrl,
  upstream: "https://hub.c.163.com/v2/"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"