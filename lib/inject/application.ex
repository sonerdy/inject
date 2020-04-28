defmodule Inject.Application do
  use Application

  def start(_type, _args) do
    children = [Inject]

    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Inject.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
