# Inject

Inject is a library that lets you write testable Elixir code that can run concurrently in ExUnit.

## Installation

```elixir
def deps do
  [
    {:inject, "~> 0.2.0"}
  ]
end
```

It is recommended to disable inject in prod.exs to avoid any performance penalty for registry lookups.
```
config :inject, disabled: true
```

## Usage

Inject is just a couple of functions.

- `inject/1` aliased as `i/1`. Use this function in your implementation code to flag modules for potential injection.

```elixir
defmodule MyApplication do
  import Inject, only: [i: 1]

  def process do
    {:ok, file} = i(File).open("your-mind.txt", [])
    ...
  end
end
```

- `register/2` `register/3`. Use this function in your tests to register a stubbed implementation for a module.

```elixir
defmodule MyApplicationTest do
  use ExUnit.Case, async: true
  import Inject, only: [register: 2]

  defmodule FileStub do
    def open("your-mind.txt", _opts) do
      {:ok, nil}
    end
  end

  test "use my stub for this test" do
    register(File, FileStub)
    {:ok, nil} = MyApplication.process()
  end
end
```
Defining stubbed modules like this is great, but I like to pair Inject w/ [Double](https://hex.pm/packages/double) for on-the-fly setups.

```elixir
defmodule MyApplicationTest do
  use ExUnit.Case, async: true
  import Inject, only: [register: 2]
  import Double

  test "use my stub for this test" do
    register(File, stub(File, :open, fn(_, _) -> {:ok, nil} end))
    {:ok, nil} = MyApplication.process()
  end
end
```

### Shared Mode
If you want to inject a dependency that will be shared by all processes, you can do so by passing the `shared: true` option.
This can be useful if you have background processing. This is only recommended for tests that do not run async.

```elixir
register(File, FileStub, shared: true)
```

## TODO
- Add `allow/1` for enabling another process to use registrations from the current test.
