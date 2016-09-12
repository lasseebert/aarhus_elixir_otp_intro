defmodule KV.Store do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def insert(pid, key, value) do
    GenServer.call(pid, {:insert, key, value})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  # Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:insert, key, value}, _from, state) do
    {:reply, :ok, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end
end
