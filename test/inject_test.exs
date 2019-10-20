defmodule InjectTest do
  use ExUnit.Case
  import Inject, only: [i: 1, register: 2]
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

  # TODO implement allowing other processes
  # describe "when allowing another process" do
  # test "it injects dependencies within another process" do
  # test_pid = self()
  # pid = spawn fn ->
  # receive do
  # :go -> send test_pid, i(ExampleModule).hello()
  # end
  # end

  # register(ExampleModule, StubModule)
  # allow(pid)

  # send pid, :go
  # assert_receive "stubbed"
  # end
  # end
end
