defmodule KV.Registry do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def store_for(key) do
    GenServer.call(__MODULE__, {:store_for, key})
  end

  def init(:ok) do
    stores = %{}
    refs = %{}
    {:ok, {stores, refs}}
  end

  def handle_call({:store_for, key}, _from, state) do
    first = String.first(key)
    {state, pid} = find_or_create(state, first)
    {:reply, pid, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {stores, refs}) do
    {first, refs} = Map.pop(refs, ref)
    stores = Map.delete(stores, first)
    {:noreply, {stores, refs}}
  end

  defp find_or_create({stores, _refs} = state, first) do
    case Map.get(stores, first) do
      nil -> create(state, first)
      pid -> {state, pid}
    end
  end

  defp create({stores, refs}, first) do
    {:ok, pid} = KV.Store.Supervisor.start_child
    ref = Process.monitor(pid)
    stores = Map.put(stores, first, pid)
    refs = Map.put(stores, ref, first)
    {{stores, refs}, pid}
  end
end
