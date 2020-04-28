defmodule Inject do
  use GenServer

  def register(source_module, inject_module, opts \\ []) do
    shared = opts |> Keyword.get(:shared, false)
    {:ok, _} = GenServer.call(__MODULE__, {:register, source_module, inject_module, shared})
    :ok
  end

  def i(mod), do: inject(mod)

  def inject(mod) do
    if Application.get_env(:inject, :disabled) do
      mod
    else
      {:ok, registered} = GenServer.call(__MODULE__, {:lookup, mod})
      registered
    end
  end

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @impl true
  def init(_), do: {:ok, %{}}

  @impl true
  def handle_call({:register, module, registered_module, shared}, {pid, _ref}, registrations) do
    mod_registrations = registrations |> Map.get(module, %{})

    new_mod_registrations =
      if shared do
        Map.put(mod_registrations, :shared, {pid, registered_module})
      else
        Map.put(mod_registrations, pid, registered_module)
      end

    new_registrations = Map.put(registrations, module, new_mod_registrations)

    Process.monitor(pid)

    {:reply, {:ok, mod_registrations}, new_registrations}
  end

  @impl true
  def handle_call({:lookup, module}, {pid, _ref}, registrations) do
    result =
      lookup_registered(registrations, module, pid) ||
        lookup_shared(registrations, module) ||
        module

    {:reply, {:ok, result}, registrations}
  end

  @impl true
  def handle_info(args, state) do
    new_state =
      case args do
        {:DOWN, _ref, :process, pid, _} -> clean_registrations(state, pid)
        _ -> state
      end

    {:noreply, new_state}
  end

  defp clean_registrations(registrations, pid) do
    Enum.reduce(registrations, %{}, fn {key, value}, acc ->
      module_registrations = clean_module_registrations(value, pid)

      case module_registrations do
        %{} -> acc
        _ -> Map.put(acc, key, module_registrations)
      end
    end)
  end

  defp clean_module_registrations(registrations, pid) do
    case Map.get(registrations, :shared) do
      {^pid, _} -> Map.delete(registrations, :shared)
      _ -> registrations
    end
    |> Map.delete(pid)
  end

  defp lookup_registered(registrations, module, pid) do
    registrations
    |> Map.get(module, %{})
    |> Map.get(pid) || false
  end

  defp lookup_shared(registrations, module) do
    with mod_registrations <- Map.get(registrations, module, %{}),
         {shared_by, registered} <- Map.get(mod_registrations, :shared),
         true <- Process.alive?(shared_by) do
      registered
    else
      _ -> false
    end
  end
end
