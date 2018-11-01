defmodule Neurotic do
  alias Neurotic.LearnerSupvisor
  alias Neurotic.Learner
  alias Neurotic.Datum

  def start_learner(name, data, arg_width) do
    {:ok, name} = LearnerSupvisor.new_learner(name)
    Learner.load_training_data(name, data, arg_width)
    name
  end

  def xor do
    {:ok, learner} = LearnerSupvisor.new_learner(:learner)
    {:ok, input} = Learner.init_neuron(learner, :input)
    {:ok, hidden1} = Learner.init_neuron(learner, :hidden1)
    {:ok, hidden2} = Learner.init_neuron(learner, :hidden2)

    LearnerSupvisor.setup(learner, [
      {input, 2, hidden1, 2},
      {input, 2, hidden2, 2},
      {[hidden1, hidden2], 1, :out}
    ])
  end

  def go do
    stream = File.stream!("./sonar.all-data.txt", [], :line)

    data =
      Enum.map(stream, fn row ->
        data = String.split(row, ",")
        expect = if List.last(data) =~ "M", do: 1, else: 0

        data =
          Enum.take(data, Enum.count(data) - 1)
          |> Enum.map(fn x -> elem(Float.parse(x), 0) end)

        %Datum{expected: expect, args: data}
      end)

    {train, eval} = Enum.split(data, 180)
    start_learner("abc", train, 59)
    # verify_learner()
  end
end
