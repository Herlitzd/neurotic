defmodule Neurotic.Nueron do
  use GenServer
  alias Neurotic.Datum

  def rate do
    Application.get_env(:nuertotic, :rate, 0.01)
  end

  def init({_bias, _weights} = args) do
    {:ok, args}
  end

  def train_epochs(pid, data, epochs) do
    GenServer.call(pid, {:train_epochs, data, epochs}, :infinity)
  end

  def evaluate(pid, data) do
    GenServer.call(pid, {:evaluate, data}, :infinity)
  end

  def handle_call({:evaluate, data}, _from, {bias, weights} = state) do
    {:reply, Enum.map(data, fn datum -> activate(datum, state) end), state}
  end

  import IEx

  def handle_call({:train_epochs, data, epochs}, _from, {_bias, _weights} = state) do
    state =
      Enum.reduce(0..epochs, state, fn _, acc ->
        epoch(data, acc)
      end)

    {:reply, state, state}
  end

  def epoch(data, {bias, weights} = state) do
    rate = rate()
    # IEx.pry()

    {bias, weights, error} =
      Enum.reduce(data, {bias, weights, 0.0}, fn datum, {bias, weights, sum_error} ->
        processed = activate(datum, state)
        # zero for correct classification
        error = processed.expected - processed.predicted
        bias = bias + rate * error

        weights =
          Enum.map(weights |> Enum.with_index(), fn {weight, index} ->
            weight + rate * error * Enum.at(datum.args, index)
          end)

        {bias, weights, sum_error + error * error}
      end)

    # IO.puts("Error for epoch: #{error}")
    # IO.puts("Weights #{inspect(weights |> Enum.map(&Float.round(&1, 3)))}")
    # IO.puts("Bias #{inspect(bias)}")

    {bias, weights}
  end

  def activate(datum, {bias, weights}) do
    activation =
      Enum.with_index(weights)
      |> Enum.reduce(bias, fn {w, index}, acc ->
        acc + w * Enum.at(datum.args, index)
      end)

    predicted = if activation < 0, do: 0, else: 1
    %Datum{datum | predicted: predicted}
  end
end
