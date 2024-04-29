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
      {:error, %Omise.Error{code: "too_many_requests"}} -> {:error, :too_many_requests}
      # Handle other errors
      {:error, error} -> {:error, error}
    end
  end

  def charge(amount) do
    case token("Anthony", "4242424242424242") do
      {:ok, token} ->
        charge_params = [amount: amount, currency: "thb", card: token.id]

        with {:ok, charge} <- Omise.Charge.create(charge_params) do
          # handle success
          IO.puts("Thank you :)")
          charge
        else
          {:error, code: "too_many_requests"} ->
            IO.puts("Too many requests")
            :error
        end

      {:error, reason} ->
        IO.puts(reason)
        :error
    end
  end
end
