# Logdna
[![Build Status](https://travis-ci.org/Waasi/logdna.svg?branch=master)](https://travis-ci.org/Waasi/logdna)

LogDNA Logger Backend

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `logdna` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logdna, "~> 0.0.0"}
  ]
end
```

## LogDNA Configuration

```elixir
config :logdna, :config,
  max_buffer: <desired_buffer_size>, # default is 10
  app: System.get_env("LOGDNA_APP") || "app",
  ingestion_key: System.get_env("LOGDNA_KEY"),
  hostname: System.get_env("LOGDNA_HOSTNAME") || "localhost"
```

## Logger Configuration

Configure the following as you would for console backend

```elixir
config :logger, :logdna,
  level: :info,
  format: "$time $metadata[$level] $message\n"
```

## Running Tests

`MIX_ENV=test mix test`

## Contributing

1. Fork it ( https://github.com/[my-github-username]/logdna/fork )
2. Create your feature branch (git checkout -b feature/my_new_feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request