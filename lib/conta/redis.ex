defmodule Conta.Redis do
  use Supervisor

  def command(args, opts \\ []) do
    :poolboy.transaction(
      :worker,
      fn worker -> GenServer.call(worker, {:command, args, opts}) end,
      5000
    )
  end

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      :poolboy.child_spec(:worker, poolboy_config())
    ]

    opts = [strategy: :one_for_one, name: PoolboyApp.Supervisor]

    Supervisor.init(children, opts)
  end

  defp poolboy_config do
    [
      name: {:local, :worker},
      worker_module: Conta.Redis.Worker,
      size: 5,
      max_overflow: 2
    ]
  end
end
