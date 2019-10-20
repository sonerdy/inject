defmodule Inject.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: Inject.Registry]}
    ]

    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Inject.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
