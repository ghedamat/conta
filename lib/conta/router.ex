defmodule Conta.Router do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    # TODO cache image payload in memory
    {:ok, resp} = File.read("public/1x1.png")

    conn
    |> put_resp_content_type("image/png")
    |> send_resp(200, resp)
  end
end
