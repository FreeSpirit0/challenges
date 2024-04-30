defmodule OpnTest do
  use ExUnit.Case
  import Mock
  import Payment.Opn

  test "create token return token" do
    Mock.with_mock Omise.Token,
      create: fn
        _ ->
          {:ok, %Omise.Token{}}
      end do
      assert create_token("Labubu", "4111111111111111") == {:ok, %Omise.Token{}}
    end
  end

  test "create charge return charge" do
    Mock.with_mock Omise.Charge,
      create: fn
        _ ->
          {:ok, %Omise.Charge{}}
      end do
      assert create_charge("2000", "tokn_test_5zlei799wdoe6egskrf") ==
               {:ok, %Omise.Charge{}}
    end
  end

  test "charge ok when can create token and charge" do
    Mock.with_mock Payment.Opn,
      create_charge: fn _, _ -> {:ok, %Omise.Charge{}} end,
      create_token: fn _, _ -> {:ok, %Omise.Token{}} end do
      assert charge("2000", "Labubu", "4111111111111111") == {:ok, %Omise.Charge{}}
    end
  end

  test "retry mechanism retries when rate limited" do
    import Payment.Opn

    Mock.with_mock Payment.Opn,
      create_token: fn
        _name, _credit_card ->
          [
            {:error, %Omise.Error{code: "too_many_requests"}}
          ]
      end do
      res = charge("20000", "Labubu", "4111111111111111")
      Mock.assert_called_exactly(Payment.Opn.create_token(:_, :_), 5)

      assert res == {:error, :retry_limit_exceeded}
    end
  end
end
