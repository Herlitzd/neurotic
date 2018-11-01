defmodule Neurotic.LearnerSupvisor do
  use DynamicSupervisor
  alias Neurotic.Learner

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def new_learner(name) do
    name = get_name(name)
    {:ok, _pid} = DynamicSupervisor.start_child(__MODULE__, {Neurotic.Learner, name})
    {:ok, name}
  end

  def setup(learner, neurons) do
    Enum.map(neurons, fn n -> configure_neuron(learner, n) end)
  end

  defp configure_neuron(learner, config) do
    Learner.configure_neuron(learner, config)
  end

  defp get_name(name) do
    {:via, Registry, {Neurotic.LearnerRegistry, name}}
  end
end
