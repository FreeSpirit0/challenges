defmodule Payment.Opn do
  def token(name, credit_card) do
    case Omise.Token.create(
           card: [
             name: name,
             number: credit_card,
             expiration_month: 10,
             expiration_year: 2025,
             city: "Bangkok",
             postal_code: "10320",
             security_code: 123
           ]
         ) do
      {:ok, token} -> {:ok, token}
      {:error, %Omise.Error{code: "too_many_requests"}} ->
        :timer.sleep(200)
        token(name, credit_card)
      {:error, error} -> {:error, error}
    end
  end

  def charge(amount) do
    with {:ok, token} <- token("Anthony", "4242424242424242"),
         {:ok, charge} <- Omise.Charge.create(amount: amount, currency: "thb", card: token.id) do
      IO.puts("Thank you :)")
      charge
    else
      {:error, %Omise.Error{code: "too many requests"}} ->
        :timer.sleep(200)
        charge(amount)
      {:error, %Omise.Error{code: code, message: message}} ->
        IO.puts("#{code} #{message}")
    end
  end
end
