defmodule Neurotic.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Neurotic.Learner
  alias Neurotic.Datum
  import IEx

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Learner, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Neurotic.Supervisor]
    main = Supervisor.start_link(children, opts)

    Task.start_link(&train_and_run/0)

    main
  end

  def train_and_run() do
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
    Neurotic.Learner.load_training_data(train)
    Neurotic.Learner.verify_training(eval)
  end

  def init([]) do
    IO.puts("init")
  end
end
