defmodule InjectConfigurationTest do
  use ExUnit.Case, async: false
  import Inject
  doctest Inject

  defmodule ExampleModule do
    def hello do
      "unstubbed"
    end
  end

  defmodule StubModule do
    def hello do
      "stubbed"
    end
  end

  describe "when inject is disabled via configuration" do
    test "it does not lookup modules in the registry" do
      register(ExampleModule, StubModule)
      Application.put_env(:inject, :disabled, true)
      assert {"unstubbed", []} = Code.eval_quoted(quote(do: inject_module(ExampleModule).hello()))
      Application.put_env(:inject, :disabled, false)
    end
  end
end
