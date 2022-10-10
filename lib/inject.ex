defmodule Inject do
  def register(source_module, inject_module, opts \\ []) do
    shared = opts |> Keyword.get(:shared, false)

    {:ok, _} =
      Registry.register(Inject.Registry, source_module, {inject_module, [shared: shared]})

    :ok
  end

  defmacro inject_module(mod) do
    if Application.get_env(:inject, :disabled) do
      mod
    else
      quote bind_quoted: [mod: mod] do
        Inject.Registry
        |> Registry.lookup(mod)
        |> Enum.reverse()
        |> find_override() || mod
      end
    end
  end

  def i(mod) do
    inject(mod)
  end

  def inject(mod) do
    inject_module(mod)
  end

  defp find_override([]), do: nil

  defp find_override([{pid, {override, shared: shared}} | overrides]) do
    if pid == self() || shared do
      override
    else
      find_override(overrides)
    end
  end
end
