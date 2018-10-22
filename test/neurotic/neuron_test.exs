defmodule Neurotic.NeuronTest do
  use ExUnit.Case
  alias Neurotic.Datum
  alias Neurotic.Neuron
  @datum %Datum{args: [0, 1], expected: 0}

  test "positive activation with zero weights" do
    # result should be 0.5
    result = Neuron.activate(@datum, {0.5, [0, 0]})
    assert result.predicted == 1
  end

  test "positive activation with one weights" do
    # result should be 0.5
    result = Neuron.activate(@datum, {0.5, [1, 1]})
    assert result.predicted == 1
  end

  test "negative activation with negative weights" do
    # result should be 0.5
    result = Neuron.activate(@datum, {0.5, [-1, -1]})
    assert result.predicted == 0
  end

  test "negative activation with negative bias" do
    # result should be 0.5
    result = Neuron.activate(@datum, {-0.5, [0, 0]})
    assert result.predicted == 0
  end

  test "epoch" do
    data = Enum.map(0..1, fn _ -> @datum end)
    {bias, [w1, w2]} = Neuron.epoch(data, 1, {0.5, [0, 0]})
    # false positive activation on both entries so:
    # bias + rate * +/-error
    # 0.5 + 0.5 * - 1 = 0
    # 0.0 + 0.5 * - 1 = -0.5
    assert bias == -0.5
    # arg at index 0 is 0, coef cannot change
    assert w1 == 0
    #  0.0 + 0.5 * -1 * 1 = -0.5
    # -0.5 + 0.5 * -1 * 1 = -1.0
    assert w2 == -1.0
  end
end
