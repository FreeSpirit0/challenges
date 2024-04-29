defmodule Tamboon do
  import Payment.Opn
  @moduledoc """
  Documentation for `Tamboon`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Tamboon.hello()
      :world

  """
  def csv do
    "../../donation.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode()
    |> Enum.to_list()
  end

  def run_omise_concurrently(n) do
    # Start n concurrent tasks
    tasks =
      1..n
      |> Enum.map(fn _ -> Task.async(fn -> charge(1000_00) end) end)

    # Wait for all tasks to finish
    tasks_with_results = Task.yield_many(tasks, :infinity)

    results =
      Enum.map(tasks_with_results, fn {task, res} ->
        #### Shut down the tasks that did not reply nor exit
        res || Task.shutdown(task, :brutal_kill)
      end)
    successful = Enum.count(results, &elem(&1, 1) == :ok)
    failed = Enum.count(results, &elem(&1, 1) != :ok)
    IO.puts("Successfully processed #{successful} out of #{n} requests.")
    IO.puts("Failed #{failed} requests.")
  end

  def test do
    1 + 1
  end
end
