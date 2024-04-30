defmodule Tamboon do
  import Payment.Opn
  import Csv.Reader
  import Summary.Insight

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
      csv()
      |> Enum.map(fn {:ok, [name, card, amount]} ->
        Task.async(fn -> charge(amount, name, card) end)
      end)

    tasks_with_results = Task.yield_many(tasks, :infinity)

    results =
      Enum.map(tasks_with_results, fn {task, res} ->
        res || Task.shutdown(task, :brutal_kill)
      end)

    {successful, failed} =
      Enum.split_with(results, fn
        {:ok, _ = {_, %Omise.Charge{}}} -> true
        {:ok, :error} -> false
        _ -> false
      end)

    total = successful |> total()

    average = successful |> average()

    top =
      successful
      |> top()

    IO.puts("Total Donation: #{total}")
    IO.puts("Average Donation: #{average}")
    IO.puts("Successful Charge: #{length(successful)}")
    IO.puts("Failed Charge: #{length(failed)}")
    IO.puts("Top 5 Donations:")
    IO.puts(top |> Enum.map(fn [name: name, amount: amount] -> "#{name}: #{amount} THB \n" end))
  end

  def test do
    1 + 1
  end
end
