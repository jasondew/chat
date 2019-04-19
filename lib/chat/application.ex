defmodule Chat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port =
      String.to_integer(System.get_env("PORT") || raise("missing $PORT environment variable"))

    # List all child processes to be supervised
    children = [
      {Task.Supervisor, name: Chat.ConnectionSupervisor},
      Supervisor.child_spec({Task, fn -> Chat.Connection.accept(port) end}, restart: :permanent),
      {Chat.Room, name: Chat.Room}
      # Starts a worker by calling: Chat.Worker.start_link(arg)
      # {Chat.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
