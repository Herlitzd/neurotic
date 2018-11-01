defmodule Neurotic.Neuron do
  use GenServer
  alias Neurotic.Datum

  def rate do
    Application.get_env(:neurotic, :rate, 0.01)
  end

  def init(_args) do
    {:ok, {0.0, [], nil}}
  end

  def train_epochs(pid, data, epochs) do
    GenServer.call(pid, {:train_epochs, data, epochs}, :infinity)
  end

  def config(neuron, {_bias, _weights, _output} = state) do
    GenServer.call(neuron, {:config, state})
  end

  def evaluate(pid, data) do
    GenServer.call(pid, {:evaluate, data}, :infinity)
  end

  def handle_call({:config, state}, _from, _state) do
    {:reply, :ok, state}
  end

  def handle_call({:evaluate, data}, _from, {_bias, _weights, _output} = state) do
    {:reply, Enum.map(data, fn datum -> activate(datum, state) end), state}
  end

  def handle_call({:train_epochs, data, epochs}, _from, {_bias, _weights, _output} = state) do
    state = epoch(data, epochs, state)

    {:reply, state, state}
  end

  def epoch(data, epochs_remaining, {bias, weights, output} = state) do
    rate = rate()

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

        {bias, weights, sum_error + abs(error)}
      end)

    cond do
      error == 0 or epochs_remaining == 0 ->
        # if zero error is achieved accross epoch, training is complete
        # short circuit and exit
        {bias, weights}

      true ->
        epoch(data, epochs_remaining - 1, {bias, weights, output})
    end
  end

  def activate(datum, {bias, weights, _output}) do
    activation =
      Enum.with_index(weights)
      |> Enum.reduce(bias, fn {w, index}, acc ->
        acc + w * Enum.at(datum.args, index)
      end)

    predicted = if activation < 0, do: 0, else: 1
    %Datum{datum | predicted: predicted}
  end
end
