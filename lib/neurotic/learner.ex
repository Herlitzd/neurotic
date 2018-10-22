defmodule Neurotic.Learner do
  use GenServer
  alias Neurotic.Neuron

  def init(arg) do
    {:ok, arg}
  end

  def load_training_data(data) do
    GenServer.call(__MODULE__, {:load_training_data, data}, :infinity)
  end

  def verify_training(test_data) do
    GenServer.cast(__MODULE__, {:verify_training, test_data})
  end

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, {[], nil}, name: __MODULE__)
  end

  def handle_call({:load_training_data, data}, _from, {_data, _pid}) do
    # IO.inspect(Enum.at(data, 50))
    epochs = Application.get_env(:neurotic, :epochs, 5)
    count = Enum.count(List.first(data).args)
    start_weights = Enum.map(0..(count - 1), fn _ -> 0.0 end)
    {:ok, pid} = GenServer.start_link(Neuron, {0, start_weights})
    Neuron.train_epochs(pid, data, epochs)
    {:reply, :ok, {data, pid}}
  end

  def handle_cast({:verify_training, test_data}, {data, pid}) do
    out = Neuron.evaluate(pid, test_data)
    correct = Enum.filter(out, fn x -> x.expected == x.predicted end)
    IO.inspect(Enum.count(correct) / Enum.count(test_data))
    IO.puts("#{inspect(Enum.count(correct))} / #{inspect(Enum.count(out))}")
    {:noreply, {data, pid}}
  end
end
