defmodule Neurotic.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Neurotic.Learner
  alias Neurotic.LearnerSupvisor
  alias Neurotic.Datum

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # {Learner, []}
      {LearnerSupvisor, []},
      {Registry, keys: :unique, name: Neurotic.LearnerRegistry},
      {Registry, keys: :unique, name: Neurotic.NeuronRegistry}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Neurotic.Supervisor]
    main = Supervisor.start_link(children, opts)

    # {:ok, pid} = LearnerSupvisor.new_learner("Learner 1")

    # {:ok, _pid} = Task.start_link(&train_and_run/1(pid))

    main
  end

  # def train_and_run(pid) do
  #   stream = File.stream!("./sonar.all-data.txt", [], :line)

  #   data =
  #     Enum.map(stream, fn row ->
  #       data = String.split(row, ",")
  #       expect = if List.last(data) =~ "M", do: 1, else: 0

  #       data =
  #         Enum.take(data, Enum.count(data) - 1)
  #         |> Enum.map(fn x -> elem(Float.parse(x), 0) end)

  #       %Datum{expected: expect, args: data}
  #     end)

  #   {train, eval} = Enum.split(data, 180)
  #   Neurotic.Learner.load_training_data(train)
  #   Neurotic.Learner.verify_training(eval)
  # end

  def init([]) do
    IO.puts("init")
  end
end
