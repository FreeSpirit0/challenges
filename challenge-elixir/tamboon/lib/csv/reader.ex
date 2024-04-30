defmodule Csv.Reader do
  @moduledoc """
  CSV Reader.
  """

  @doc """
  Load donation.csv and get rid of header row.
  """
  @spec csv() :: [[String.t()]]
  def csv do
    "../donation.csv"
    |> Path.expand(File.cwd!())
    |> File.stream!()
    |> CSV.decode()
    |> Enum.to_list()
    |> tl()
  end
end
