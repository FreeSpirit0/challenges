defmodule Tamboon do
  import Payment.Opn
  import Csv.Reader

  @moduledoc """
  Documentation for `Tamboon`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Tamboon.hello()
      :world

  """
  def run_charges_concurrently do
    tasks =
      csv() |> Enum.map(fn {:ok, [name, card, amount]} -> Task.async(fn -> charge(amount, name, card) end) end)

    tasks_with_results = Task.yield_many(tasks, :infinity)

    results =
      Enum.map(tasks_with_results, fn {task, res} ->
        res || Task.shutdown(task, :brutal_kill)
      end)

    {successful, failed} =
      Enum.split_with(results, fn
        {:ok, _ = %Omise.Charge{}} -> true
        {:ok, :error} -> false
        _ -> false
      end)

    total =
      successful
      |> Enum.map(&elem(&1, 1))
      |> Enum.map(fn charge -> charge.amount end)
      |> Enum.sum()

    average =
      total / length(successful)

    IO.puts("Total Donation: #{total}")
    IO.puts("Average Donation: #{average}")
    IO.puts("Successful Charge: #{length(successful)}")
    IO.puts("Failed Charge: #{length(failed)}")
  end

  def test do
    1 + 1
  end
end
