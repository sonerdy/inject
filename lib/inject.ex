defmodule Inject do
  def register(source_module, inject_module, opts \\ []) do
    shared = opts |> Keyword.get(:shared, false)

    {:ok, _} =
      Registry.register(Inject.Registry, source_module, {inject_module, [shared: shared]})

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
      |> Enum.reverse()
      |> find_override() || mod
    end
  end

  defp find_override([]), do: nil

  defp find_override(overrides) do
    overrides
    |> Enum.reduce_while(nil, fn
      {pid, {override, _}}, _acc when pid == self() ->
        {:halt, override}

      {_, {override, [shared: true]}}, nil ->
        {:cont, override}

      _, acc ->
        {:cont, acc}
    end)
  end
end
