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
# Configures the endpoint

config :server,
       Server.Endpoint,
       url: [
         host: "localhost"
       ],
       secret_key_base: "ebNdrraHv11O2vWKYGJ8IO1GBF2MIAt3gSpiIImCF7z8wp7lwRBupndORHN+ntWf",
       render_errors: [
         view: Server.ErrorView,
         accepts: ~w(json)
       ]

config :mime, :types, %{
  "application/vnd.docker.distribution.manifest.v1+prettyjws" => ["manifest.v1-prettyjws"],
  "application/vnd.docker.distribution.manifest.v2+json" => ["manifest.v2-json"],
  "application/vnd.docker.distribution.manifest.list.v2+json" => ["manifest.v2.list-json"]
}

import_config "#{Mix.env}.exs"