defmodule Conta.Router do
  use Plug.Router
  plug(:match)
  plug(:dispatch)

  match _ do
    # TODO cache image payload in memory
    app_dir = Application.app_dir(:conta, "priv")
    {:ok, resp} = File.read("#{app_dir}/1x1.png")

    path = conn.request_path

    set = "VISITS:#{path}"
    key = Date.utc_today() |> Date.to_string()

    IO.inspect(set)
    Conta.Redis.command(["HINCRBY", set, key, 1])

    conn
    |> put_resp_content_type("image/png")
    |> send_resp(200, resp)
  end
end
