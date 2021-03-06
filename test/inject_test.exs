defmodule InjectTest do
  use ExUnit.Case, async: true
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

  defmodule StubModule2 do
    def hello do
      "stubbed2"
    end
  end

  describe "when not registering a dependency" do
    test "it uses the source module" do
      assert "unstubbed" = i(ExampleModule).hello()
    end
  end

  describe "when registering a dependency" do
    setup do
      register(ExampleModule, StubModule)
    end

    test "it uses the registered dependency" do
      assert "stubbed" = i(ExampleModule).hello()
    end
  end

  describe "when re-registering a dependency" do
    setup do
      register(ExampleModule, StubModule)
    end

    test "it uses the last registered dependency" do
      register(ExampleModule, StubModule2)
      assert "stubbed2" = i(ExampleModule).hello()
    end
  end

  describe "when registering in a separate process" do
    test "it does not inject the dependencies for another process" do
      test_pid = self()

      spawn(fn ->
        register(ExampleModule, StubModule)
        send(test_pid, :registered)
      end)

      assert_receive :registered

      assert "unstubbed" = i(ExampleModule).hello()
    end
  end

  test "avoids the :already_registered error" do
    test_pid = self()

    # register a bunch of times to get the :already_registered error to happen
    pid1 =
      spawn(fn ->
        register(ExampleModule, StubModule)
        register(ExampleModule, StubModule2)
        register(ExampleModule, StubModule)
        register(ExampleModule, StubModule2)
        register(ExampleModule, StubModule)
        register(ExampleModule, StubModule2)
        register(ExampleModule, StubModule)

        receive do
          :go -> send(test_pid, {:first, i(ExampleModule).hello()})
        end
      end)

    pid2 =
      spawn(fn ->
        register(ExampleModule, StubModule)
        register(ExampleModule, StubModule2)
        register(ExampleModule, StubModule)
        register(ExampleModule, StubModule2)
        register(ExampleModule, StubModule)
        register(ExampleModule, StubModule2)

        receive do
          :go -> send(test_pid, {:second, i(ExampleModule).hello()})
        end
      end)

    send(pid1, :go)
    send(pid2, :go)

    assert_receive {:first, "stubbed"}
    assert_receive {:second, "stubbed2"}
  end

  describe "when registering in shared mode" do
    test "it allows any other processes to use the registration" do
      test_pid = self()

      pid =
        spawn(fn ->
          receive do
            :go -> send(test_pid, i(ExampleModule).hello())
          end
        end)

      register(ExampleModule, StubModule, shared: true)

      send(pid, :go)
      assert_receive "stubbed"
    end
  end
end
