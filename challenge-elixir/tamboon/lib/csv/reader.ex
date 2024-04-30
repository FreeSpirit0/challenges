defmodule Csv.Reader do
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
