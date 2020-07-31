defmodule Woke.AlarmHandler do
  require Logger

  def init_resource(resource) do
    :gen_event.call(:alarm_handler, __MODULE__, {:init, resource})
  end

  def get_alarms() do
    :gen_event.call(:alarm_handler, __MODULE__, :get_alarms)
  end

  def init({:ok, {:alarm_handler, _old_alarms}}) do
    Logger.info("Installed #{__MODULE__} alarm as handler ")
    {:ok, %{events: [], resources: Map.new()}}
  end

  def handle_event({:set_alarm, {resource, message}}, %{events: events, resources: resources}) do
    Logger.error(
      "Alarm:  #{__MODULE__} for #{inspect(resource)} fired. Message: #{inspect(message)} "
    )

    state = %{
      events: [{:os.system_time(:seconds), {"alarm_set", resource}} | events],
      resources: Map.put(resources, resource, :down)
    }

    {:ok, state}
  end

  def handle_event({:clear_alarm, resource}, %{events: events, resources: resources}) do
    Logger.info("Alarm: #{__MODULE__} for #{inspect(resource)} cleared")

    state = %{
      events: [{:os.system_time(:seconds), {"alarm_cleared", resource}} | events],
      resources: Map.put(resources, resource, :up)
    }

    {:ok, state}
  end

  def handle_event(_event, state), do: {:ok, state}

  def handle_call(:get_alarms, state), do: {:ok, state, state}

  def handle_call({:init, resource}, %{resources: resources} = state) do
    {:ok, true, %{state | resources: Map.put(resources, resource, nil)}}
  end
end
