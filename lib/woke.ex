defmodule Woke do
  @doc "Give a resource name and it will tell you if it is up, down or nil for unknown state"
  @spec get_state(any()) :: :up | :down | nil
  def get_state(resource) do
    Map.get(resources(), resource)
  end

  @doc "Return the list of alarms and the state of the services that are monitored by Watchdog"
  def get_alarms() do
    Woke.AlarmHandler.get_alarms()
  end

  @doc "Which resources are monitored by Woke and are they up or down?"
  def resources() do
    Map.get(get_alarms(), :resources)
  end
end
