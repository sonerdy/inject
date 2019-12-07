defmodule Inject do
  def register(source_module, inject_module, opts \\ []) do
    shared = opts |> Keyword.get(:shared, false)
    :ok = Registry.unregister(Inject.Registry, source_module)
    :ok = try_register(source_module, inject_module, [shared: shared], 1)
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

  # It seems that unregister doesn't always take immediate effect so we try a few times.
  defp try_register(_source_module, _inject_module, _opts, 4) do
    {:error, "Too many attempts to register an already registered module"}
  end

  defp try_register(source_module, inject_module, opts, attempt) do
    case Registry.register(Inject.Registry, source_module, {inject_module, opts}) do
      {:ok, _} ->
        :ok

      {:error, {:already_registered, _}} ->
        try_register(source_module, inject_module, opts, attempt + 1)
    end
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
