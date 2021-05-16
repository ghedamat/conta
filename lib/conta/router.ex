defmodule Conta.Router do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    resp = Jason.encode!(%{status: :ok})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, resp)
  end
end
