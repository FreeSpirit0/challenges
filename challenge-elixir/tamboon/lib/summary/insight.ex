defmodule Summary.Insight do
  @spec total(list(Omise.Charge.t())) :: non_neg_integer()
  def total(charges) do
    charges
    |> Enum.map(fn {:ok, {_, charge}} -> charge.amount end)
    |> Enum.sum()
  end

  @spec average(list(Omise.Charge.t())) :: non_neg_integer()
  def average(charges) do
    case length(charges) do
      x when x > 0 -> total(charges) / length(charges)
      _ -> 0
    end
  end

  @spec top(list(Omise.Charge.t())) :: list(name: String.t(), amount: number())
  def top(charges) do
    charges
    |> Enum.map(fn {:ok, {name, charge}} -> [name: name, amount: charge.amount] end)
    |> Enum.group_by(fn [name: name, amount: _] -> name end)
    |> Map.values()
    |> Enum.map(fn charges ->
      charges
      |> Enum.reduce(fn [name: name, amount: amount], [name: _, amount: accAmount] ->
        [name: name, amount: amount + accAmount]
      end)
    end)
  end
end
