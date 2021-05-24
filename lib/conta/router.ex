defmodule Conta.Router do
  use Plug.Router
  plug(:match)
  plug(:dispatch)

  match _ do
    # TODO cache image payload in memory
    {:ok, resp} = File.read("public/1x1.png")

    path = conn.request_path

    set = "VISITS:#{path}"
    key = Date.utc_today() |> Date.to_string()

    Conta.Redis.command(["HINCRBY", set, key, 1])

    conn
    |> put_resp_content_type("image/png")
    |> send_resp(200, resp)
  end
end
