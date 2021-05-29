defmodule Conta.Router do
  use Plug.Router
  plug(:match)
  plug(:dispatch)

  get "/stats/:domain" do
    {:ok, res} = Conta.Redis.command(["KEYS", "VISITS:/#{domain}/*"])

    val =
      Enum.map(res, fn e ->
        {:ok, res} = Conta.Redis.command(["HGETALL", e])

        map =
          res
          |> Enum.chunk_every(2)
          |> Enum.map(fn [a, b] -> {a, b} end)
          |> Map.new()

        %{e => map}
      end)

    conn
    |> send_resp(200, Jason.encode!(val))
  end

  match _ do
    # TODO cache image payload in memory
    app_dir = Application.app_dir(:conta, "priv")
    {:ok, resp} = File.read("#{app_dir}/1x1.png")

    path = conn.request_path

    set = "VISITS:#{path}"
    key = Date.utc_today() |> Date.to_string()

    Conta.Redis.command(["HINCRBY", set, key, 1])

    conn
    |> put_resp_content_type("image/png")
    |> send_resp(200, resp)
  end
end
