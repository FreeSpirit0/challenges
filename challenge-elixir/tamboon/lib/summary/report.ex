defmodule Summary.Report do
  import Summary.Insight
  @spec report_total(non_neg_integer()) :: :ok
  def report_total(total) do
    IO.puts("Total Donation: #{total}")
  end

  @spec report_average(non_neg_integer()) :: :ok
  def report_average(average) do
    IO.puts("Average Donation: #{average}")
  end

  @spec report_successful([Omise.Charge.t()]) :: :ok
  def report_successful(successful) do
    IO.puts("Successful Charge: #{length(successful)}")
  end

  @spec report_failure([Omise.Charge.t()]) :: :ok
  def report_failure(failure) do
    IO.puts("Failed Charge: #{length(failure)}")
  end

  @spec report_top_5(list(name: String.t(), amount: number())) :: :ok
  def report_top_5(top) do
    IO.puts("Top 5 Donations:")
    IO.puts(top |> Enum.take(5) |> Enum.map(fn [name: name, amount: amount] -> "#{name}: #{amount} THB \n" end))
  end

  @spec report_full([Omise.Charge.t()], [Omise.Error.t()]) :: :ok
  def report_full(successful, failure) do
    report_total(total(successful |> Enum.map(fn {_, charge} -> charge end)))
    report_average(average(successful |> Enum.map(fn {_, charge} -> charge end)) )
    report_successful(successful)
    report_failure(failure)
    report_top_5(top(successful))
  end
end
