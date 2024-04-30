defmodule Payment.Opn do
  @retry_limit 5
  def create_token(name, credit_card) do
    Omise.Token.create(
      card: [
        name: name,
        number: credit_card,
        expiration_month: 10,
        expiration_year: 2025,
        city: "Bangkok",
        postal_code: "10320",
        security_code: 123
      ]
    )
  end

  def create_charge(amount, token) do
    Omise.Charge.create(amount: amount, currency: "thb", card: token)
  end

  def charge(amount, name, credit_card) do
    with {:ok, token} <- handle_retry(&create_token/2, [name, credit_card]),
         {:ok, charge} <- handle_retry(&create_charge/2, [amount, token.id]) do
      IO.puts("Thank you #{name} :)")
      charge
    else
      {:error, :retry_limit_exceeded} ->
        IO.puts(:retry_limit_exceeded)
        {:error, :retry_limit_exceeded}

      {:error, %Omise.Error{code: code, message: message}} ->
        IO.puts("#{code} #{message} User: #{name}")
        {:error, %Omise.Error{code: code, message: message}}
    end
  end

  defp handle_retry(fun, args, retry_count \\ 0)

  defp handle_retry(fun, args, retry_count) when retry_count <= @retry_limit do
    case apply(fun, args) do
      {:ok, result} ->
        {:ok, result}

      {:error, %Omise.Error{code: "too_many_requests"}} ->
        :timer.sleep(1000)
        handle_retry(fun, args, retry_count + 1)

      {:error, error} ->
        {:error, error}
    end
  end

  defp handle_retry(_, _, _), do: {:error, :retry_limit_exceeded}
end
