defmodule Conta.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Conta.Router, port: port()},
      Conta.Redis
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Conta.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def port do
    {port, _} =
      (System.get_env("PORT") || Application.get_env(:url_shortener, :port) || "8080")
      |> Integer.parse()

    port
  end
end
