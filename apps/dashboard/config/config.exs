# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :dashboard, Dashboard.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NeAOmFf6AMb72L5NbQWIc+HuUkYn4WbtNENUKfeiZgUI01LNmJGBCt0Bmtq6iW9F",
  render_errors: [view: Dashboard.ErrorView, accepts: ~w(json)]


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
