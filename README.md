# Chat

Start the server with `Chat.Server.start` in an IEx window. Then, in another
terminal window, start up the client with
```
PORT=42019 iex -S mix client
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `chat` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:chat, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/chat](https://hexdocs.pm/chat).
