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
      # Starts a worker by calling: Neurotic.Worker.start_link(arg)
      # {Supervisor, id: Nuerotic.Supervisor},
      {Learner, []}
      # Neurotic.Learner.
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Neurotic.Supervisor]
    main = Supervisor.start_link(children, opts)

    Task.start_link(fn ->
      # stream = File.stream!("./test.txt", [], :line)
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

      {train, eval} = Enum.shuffle(data) |> Enum.split(150)
      Enum.each(train, fn datum -> GenServer.cast(Neurotic.Learner, {:add, datum}) end)
      GenServer.cast(Neurotic.Learner, {:done, eval})
      # IEx.pry()
    end)
    # GenServer.call(Neurotic.Learner, {:eval, eval})

    # Task.

    main
  end

  def init([]) do
    IO.puts("init")
  end
end
