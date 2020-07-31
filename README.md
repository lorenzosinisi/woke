# Woke

## Monitor a new external resource

Create 2 modules and add the supervisor to your children in application.ex

1. Create the interface for the external resource, for instance one named Postgres:

```elixir
defmodule MyApp.Woke.Postgres do
  @moduledoc false
  @behaviour Woke.ExternalResource

  @impl Woke.ExternalResource
  def try_connect(opts \\ []) do
    try do
      true = Postgres.query("my query")

      :connected
    rescue
      error ->
        {:error, error}
    catch
      _, error ->
        {:error, error}
    end
  end
end
```

2. Configure the external resource being monitored using a GenServer: 

```elixir
defmodule MyApp.Woke.PostgresConnections do
  use Supervisor
  alias Woke.ExternalResource
  alias MyApp.Woke.Postgres

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = all_child_specs()
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp all_child_specs() do
    database_number = [1,2,3]

    Enum.map(database_number, fn shard_id ->
      opts = [
        name: "postgres_#{shard_id}",
        check_every: :timer.seconds(30),
        try_connect_mod: Postgres,
        timeout: :timer.seconds(3)
      ]

      Supervisor.child_spec({ExternalResource, opts}, id: :"postgres_#{shard_id}")
    end)
  end
end
```

3. Add `MyApp.Woke.PostgresConnections` to your app supervisor children list:

```
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

   :gen_event.swap_handler(
        :alarm_handler,
        {:alarm_handler, :swap},
        {Woke.AlarmHandler, :ok}
    )

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(MyApp.Endpoint, []),
      MyApp.Woke.PostgresConnections
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

```

