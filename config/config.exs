use Mix.Config

config :logdna, :config,
  app: System.get_env("LOGDNA_APP") || "app",
  ingestion_key: System.get_env("LOGDNA_KEY"),
  hostname: System.get_env("LOGDNA_HOSTNAME") || "localhost"

config :logger, :logdna,
  level: :info,
  format: "$time $metadata[$level] $message\n"

config :logger,
  backends: [Logdna.Backend, :console]