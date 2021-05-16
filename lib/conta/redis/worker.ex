defmodule Conta.Redis.Worker do
  use GenServer

  @redis_url "redis://localhost:6379"

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{conn: nil}, [])
  end

  def init(state) do
    {:ok, state}
  end

  # TODO consider starting link on init instead
  def handle_call({command, args, opts}, _from, %{conn: nil}) do
    conn = connect()
    {:reply, apply(Redix, command, [conn, args, opts]), %{conn: conn}}
  end

  def handle_call({command, args, opts}, _from, %{conn: conn}) do
    {:reply, apply(Redix, command, [conn, args, opts]), %{conn: conn}}
  end

  defp connect do
    redis_url = System.get_env("REDIS_URL", @redis_url)
    {:ok, conn} = Redix.start_link(redis_url)
    conn
  end
end
