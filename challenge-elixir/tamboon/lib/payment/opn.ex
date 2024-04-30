defmodule Payment.Opn do
  @moduledoc """
  Provide interface to call Omise Charge API.
  """
  @retry_limit 10
  @retry_wait_time 500

  @doc """
  Create token

  ## Examples
      iex> Payment.Opn.create_token("dog", "4111111111111111")
      {:ok, %Omise.Token{}}

  """
  @spec create_token(String.t(), String.t()) :: {:error, Omise.Error.t()} | {:ok, Omise.Token.t()}
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

  @doc """
  Create charge using token.

  ## Examples
      iex> Payment.Opn.create_charge("20000", "tokn_test_5zlei799wdoe6egskrf")
      {:ok, %Omise.Charge{}}

  """
  @spec create_charge(String.t(), String.t()) ::
          {:error, Omise.Error.t()} | {:ok, Omise.Charge.t()}
  def create_charge(amount, token) do
    Omise.Charge.create(amount: amount, currency: "thb", card: token)
  end

  @doc """
  Create token and charge customer using token.

  ## Examples
      iex> Payment.Opn.charge("20000", "Labubu", "4111111111111111")
      {"Labubu", %Omise.Charge{}}

  """
  @spec charge(String.t(), String.t(), String.t()) ::
          {:error, :retry_limit_exceeded | Omise.Error.t()} | {String.t(), Omise.Charge.t()}
  def charge(amount, name, credit_card) do
    with {:ok, token} <- handle_retry(&create_token/2, [name, credit_card]),
         {:ok, charge} <- handle_retry(&create_charge/2, [amount, token.id]) do
      IO.puts("Thank you #{name} :)")
      {name, charge}
    else
      {:ok, %Omise.Charge{failure_code: failure_code}} ->
        IO.puts(failure_code)
        {:error, %Omise.Charge{failure_code: failure_code}}

      {:error, :retry_limit_exceeded} ->
        IO.puts("Retry exceeded")
        {:error, :retry_limit_exceeded}

      {:error, %Omise.Error{code: code, message: message}} ->
        IO.puts("#{code} #{message} User: #{name}")
        {:error, %Omise.Error{code: code, message: message}}

      {:error, error} ->
        IO.puts(error)
        {:error, error}
    end
  end

  @spec handle_retry(fun(), list(), non_neg_integer()) :: {:ok, any()} | {:error, any()}
  defp handle_retry(fun, args, retry_count \\ 0)

  defp handle_retry(_, _, retry_count) when retry_count == @retry_limit do
    {:error, :retry_limit_exceeded}
  end

  defp handle_retry(fun, args, retry_count) do
    case apply(fun, args) do
      {:ok, result} ->
        {:ok, result}

      {:error, %Omise.Error{code: "too_many_requests"}} ->
        :timer.sleep(@retry_wait_time * retry_count)
        handle_retry(fun, args, retry_count + 1)

      {:error, error} ->
        {:error, error}
    end
  end


end
