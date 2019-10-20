defmodule Inject do
  def register(source_module, inject_module) do
    :ok = Registry.unregister(Inject.Registry, source_module)
    {:ok, _} = Registry.register(Inject.Registry, source_module, inject_module)
    :ok
  end

  def i(mod) do
    inject(mod)
  end

  def inject(mod) do
    if Application.get_env(:inject, :disabled) do
      mod
    else
      Inject.Registry
      |> Registry.lookup(mod)
      |> find_override() || mod
    end
  end

  defp find_override([]), do: nil

  defp find_override([{pid, override} | overrides]) do
    if pid == self() do
      override
    else
      find_override(overrides)
    end
  end
end
