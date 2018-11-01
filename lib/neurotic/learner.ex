defmodule Neurotic.Learner do
  use GenServer
  alias Neurotic.Neuron

  def start_link(name) do
    GenServer.start_link(__MODULE__, {[], nil}, name: name)
  end

  def init(arg) do
    {:ok, arg}
  end

  def configure_neuron(learner, {neuron_name, input_c, output, output_c}) do
    GenServer.call(learner, {:config_neuron, neuron_name, input_c, output, output_c})
  end

  def configure_neuron(learner, {neuron_name, output_c, :out}) do
    # GenServer.call(learner, {:config_neuron, neuron_name, input_c, output, output_c})
  end

  def init_neuron(name, label) do
    GenServer.call(name, {:init_neuron, label})
  end

  def load_training_data(name, data, arg_width) do
    GenServer.call(name, {:load_training_data, data, arg_width}, :infinity)
  end

  # def verify_training(name, test_data) do
  #   GenServer.cast(name, {:verify_training, test_data})
  # end

  def handle_call({:config_neuron, neuron_name, input_c, output, _output_c}, _from, state) do
    start_weights = Enum.map(0..(input_c - 1), fn _ -> 0.0 end)
    Neuron.config(neuron_name, {0.0, start_weights, output})
    {:reply, :ok, state}
  end

  def handle_call({:init_neuron, label}, _from, state) do
    name = get_name(label)
    {:ok, _pid} = GenServer.start_link(Neuron, [], name: name)
    {:reply, {:ok, name}, state}
  end

  def handle_call({:train, data}, _from, {_data, arg_width, out}) do
    epochs = Application.get_env(:neurotic, :epochs, 5)
    start_weights = Enum.map(0..(arg_width - 1), fn _ -> 0.0 end)
    {:ok, pid} = GenServer.start_link(Neuron, {0, start_weights})
    Neuron.train_epochs(pid, data, epochs)
    {:reply, :ok, {data, arg_width, out}}
  end

  defp get_name(name) do
    {:via, Registry, {Neurotic.NeuronRegistry, name}}
  end

  # def handle_cast({:verify_training, test_data}, {data, pid}) do
  #   out = Neuron.evaluate(pid, test_data)
  #   correct = Enum.filter(out, fn x -> x.expected == x.predicted end)
  #   IO.inspect(Enum.count(correct) / Enum.count(test_data))
  #   IO.puts("#{inspect(Enum.count(correct))} / #{inspect(Enum.count(out))}")
  #   {:noreply, {data, pid}}
  # end
end
