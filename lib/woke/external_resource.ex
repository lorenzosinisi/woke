defmodule Wore.ExternalResource do
  use GenServer
  require Logger
  alias Woke.AlarmHandler

  @callback try_connect(keyword()) :: :connected | {:error, any()}

  @enforce_keys [:name, :module]
  defstruct [:name, :module, :status, :passing_checks, :opts]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %__MODULE__{
      name: Keyword.fetch!(opts, :name),
      module: Keyword.fetch!(opts, :try_connect_mod),
      status: :disconnected,
      passing_checks: 0,
      opts: opts
    }

    {:ok, state, {:continue, :try_connect}}
  end

  def handle_continue(:try_connect, %__MODULE__{name: name} = state) do
    AlarmHandler.init_resource(name)
    {:noreply, try_connect(state)}
  end

  def handle_info(:try_connect, state) do
    {:noreply, try_connect(state)}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp try_connect(%{opts: opts} = state) do
    status = do_connect(state)
    state = check_state(status, state)
    schedule_check(opts)
    state
  end

  defp schedule_check(opts) do
    wait_for = Keyword.get(opts, :check_every) || :timer.seconds(30)
    Process.send_after(self(), :try_connect, wait_for)
  end

  defp check_state(result, %__MODULE__{name: name, status: status, passing_checks: count} = state) do
    case {result, status} do
      {:connected, :connected} ->
        if count == 3, do: clear_alarm(name)
        %{state | status: :connected, passing_checks: count + 1}

      {:connected, _} ->
        %{state | status: :connected, passing_checks: 0}

      {:error, :error} ->
        state

      {:error, _} ->
        set_alarm(name)
        %{state | status: :error, passing_checks: 0}
    end
  end

  defp do_connect(%__MODULE__{module: module, opts: opts}) do
    case module.try_connect(opts) do
      :connected -> :connected
      {:error, _} -> :error
    end
  end

  defp set_alarm(alarm_id) do
    :alarm_handler.set_alarm({alarm_id, "Can't connect to #{inspect(alarm_id)}"})
  end

  defp clear_alarm(alarm_id) do
    :alarm_handler.clear_alarm(alarm_id)
  end
end
