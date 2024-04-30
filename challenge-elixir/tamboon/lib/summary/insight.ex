defmodule Summary.Insight do
  @moduledoc """
  Provide charge insights.
  """

  @doc """
  Get total amount of charges.

  ## Examples

      iex> Summary.Insight.total([%Omise.Charge{amount: 200}])
      200

  """
  @spec total(list(Omise.Charge.t())) :: non_neg_integer()
  def total(charges) do
    charges
    |> Enum.map(fn charge -> charge.amount end)
    |> Enum.sum()
  end

  @doc """
  Get average amount of charges.

  ## Examples

      iex> Summary.Insight.average([%Omise.Charge{amount: 200}])
      200.0

  """
  @spec average(list(Omise.Charge.t())) :: number()
  def average(charges) do
    case length(charges) do
      x when x > 0 -> total(charges) / length(charges)
      _ -> 0
    end
  end

  @doc """
  Get charges by descending order.

  ## Examples

      iex> Summary.Insight.top([{"Topson", %Omise.Charge{amount: 200}}, {"Mewtwo", %Omise.Charge{amount: 400}}, {"Mewtwo", %Omise.Charge{amount: 400}}])
      [[name: "Mewtwo", amount: 800], [name: "Topson", amount: 200]]
  """
  @spec top(list({String.t(), Omise.Charge.t()})) :: list(name: String.t(), amount: number())
  def top(charges) do
    charges
    |> Enum.map(fn {name, charge} -> [name: name, amount: charge.amount] end)
    |> Enum.group_by(fn [name: name, amount: _] -> name end)
    |> Map.values()
    |> Enum.map(fn charges ->
      charges
      |> Enum.reduce(fn [name: name, amount: amount], [name: _, amount: accAmount] ->
        [name: name, amount: amount + accAmount]
      end)
    end)
    |> Enum.sort_by(fn [_, amount: amount] -> amount end, &>=/2)
  end
end
