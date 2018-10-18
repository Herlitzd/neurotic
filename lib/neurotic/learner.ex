defmodule Neurotic.Learner do
  use GenServer
  alias Neurotic.Nueron

  def init(arg) do
    {:ok, arg}
  end

  def start_link(_arg) do
    GenServer.start_link(Neurotic.Learner, {[], nil}, name: Neurotic.Learner)
  end

  def handle_cast({:load_training_data, data}, {_data, _pid}) do
    epochs = Application.get_env(:neurotic, :epochs, 5)
    count = Enum.count(List.first(data).args)
    start_weights = Enum.map(0..(count - 1), fn _ -> 0.0 end)
    {:ok, pid} = GenServer.start_link(Nueron, {0, start_weights})
    Nueron.train_epochs(pid, data, epochs)
    {:noreply, {data, pid}}
  end

  def handle_cast({:verify_training, testData}, {data, pid}) do
    out = Nueron.evaluate(pid, testData)
    correct = Enum.filter(out, fn x -> x.expected == x.predicted end)
    IO.inspect(Enum.count(correct) / Enum.count(testData))
    IO.puts("#{inspect(Enum.count(correct))} / #{inspect(Enum.count(out))}")
    {:noreply, {data, pid}}
  end
end
