defmodule Tamboon do
  import Payment.Opn
  import Csv.Reader
  import Summary.Report

  @moduledoc """
  Documentation for `Tamboon`.
  """

  def main(args \\ []) do
    tamboon_from_csv()
  end

  @doc """
  Load donation.csv and process the charges then generate summary.
  """
  @spec tamboon_from_csv() :: :ok
  def tamboon_from_csv do
    tasks =
      csv()
      |> Enum.map(fn {:ok, [name, card, amount]} ->
        Task.async(fn -> charge(amount, name, card) end)
      end)

    tasks_with_results = Task.yield_many(tasks, 20000)

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

    report_full(successful |> Enum.map(fn {:ok, charge} -> charge end), failed)
  end

  def test do
    1 + 1
  end
end
