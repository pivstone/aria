use Mix.Config
config :api,
       Api.Endpoint,
       http: [
         port: 4001
       ],
       server: false,
       secret_key_base: "1ad12e21+dasd2"

config :mime, :types, %{
  "application/vnd.docker.distribution.manifest.v1+prettyjws" => ["manifest.v1-prettyjws"],
  "application/vnd.docker.distribution.manifest.v2+json" => ["manifest.v2-json"],
  "application/vnd.docker.distribution.manifest.list.v2+json" => ["manifest.v2.list-json"]
}
# Print only warnings and errors during test
config :logger, level: :warn


config :core, Storage.PathSpec,
       data_dir: System.cwd <> "/_tmp"