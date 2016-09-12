defmodule KV do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: KV.Worker.start_link(arg1, arg2, arg3)
      # worker(KV.Worker, [arg1, arg2, arg3]),
      supervisor(KV.Store.Supervisor, []),
      worker(KV.Registry, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KV.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def insert(key, value) do
    store = KV.Registry.store_for(key)
    KV.Store.insert(store, key, value)
  end

  def get(key) do
    store = KV.Registry.store_for(key)
    KV.Store.get(store, key)
  end
end
