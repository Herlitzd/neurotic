defmodule Neurotic.Learner do
  use GenServer
  alias Neurotic.Nueron
  import IEx

  def start_link(arg) do
    GenServer.start_link(Neurotic.Learner, {[], nil}, name: Neurotic.Learner)
  end

  def handle_cast({:add, datum}, {data, pid}) do
    {:noreply, {[datum | data], pid}}
  end

  def handle_call({:eval, data}, from, state) do
    IEx.pry()
    # out = Nueron.evaluate(pid, data)
    IO.inspect(state)
    {:reply, nil, state}
  end

  def handle_cast({:done, testData}, {data, _pid}) do
    epochs = Application.get_env(:neurotic, :epochs, 5)
    count = Enum.count(List.first(data).args)
    start_weights = Enum.map(0..(count - 1), fn _i -> 0.0 end)
    {:ok, pid} = GenServer.start_link(Nueron, {0, start_weights})
    Nueron.train_epochs(pid, data, epochs)
    out = Nueron.evaluate(pid, data)


    correct = Enum.filter(out, fn x -> x.expected == x.predicted end)
    IO.inspect(Enum.count(correct) / Enum.count(out))
    IO.puts("#{inspect Enum.count(correct)} / #{inspect Enum.count(out)}")
    # GenServer.call(pid, {:train_epochs, data, 5})
    {:noreply, {data, pid}}
  end
end
