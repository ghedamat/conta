defmodule Conta do
  @moduledoc """
  Documentation for `Conta`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Conta.hello()
      :world

  """
  def hello do
    Task.async(fn ->
      :poolboy.transaction(
        :worker,
        fn pid -> GenServer.call(pid, {:square_root, 2}) end,
        3000
      )
    end)
  end
end
