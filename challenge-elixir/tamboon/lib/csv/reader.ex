defmodule Csv.Reader do
  def csv do
    "../donation.csv"
    |> Path.expand(File.cwd!)
    |> File.stream!()
    |> CSV.decode()
    |> Enum.to_list()
    |> tl()
  end
end
