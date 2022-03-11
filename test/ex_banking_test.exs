defmodule ExBankingTest do
  use ExUnit.Case, async: true

  import ExBanking

  test "create new user" do
    assert create_user("Jose") == :ok
    assert create_user("Jose") == {:error, :user_already_exists}
  end

  test "deposit" do
    assert create_user("James") == :ok
    assert deposit("James", 1, "USD") == {:ok, 1}
    assert deposit("James", 2, "USD") == {:ok, 3}
    assert deposit("James", 0.01, "EUR") == {:ok, 0.01}
    assert deposit("James", 0.99, "EUR") == {:ok, 1.0}
  end

  test "withdraw" do
    assert create_user("Bill") == :ok
    assert withdraw("Bill", 1, "USD") == {:error, :not_enough_money}
    assert deposit("Bill", 3, "USD") == {:ok, 3}
    assert withdraw("Bill", 1, "USD") == {:ok, 2}
    assert withdraw("Bill", 3, "USD") == {:error, :not_enough_money}
    assert withdraw("Bill", 2, "USD") == {:ok, 0}
    assert withdraw("Bill", 1, "USD") == {:error, :not_enough_money}
  end

  test "get_balance" do
    assert create_user("Jonathan") == :ok
    assert get_balance("Jonathan", "USD") == {:ok, 0}
    assert deposit("Jonathan", 3, "USD") == {:ok, 3}
    assert get_balance("Jonathan", "USD") == {:ok, 3}
    assert withdraw("Jonathan", 1, "USD") == {:ok, 2}
    assert get_balance("Jonathan", "USD") == {:ok, 2}
  end

  test "send" do
    assert create_user("From") == :ok
    assert create_user("To") == :ok
    assert deposit("From", 3, "USD") == {:ok, 3}
    assert deposit("To", 2, "USD") == {:ok, 2}
    assert send("From", "Not-exist-user", 3, "USD") == {:error, :receiver_does_not_exist}
    assert send("Not-exist-user", "To", 3, "USD") == {:error, :sender_does_not_exist}
    assert send("From", "To", 4, "USD") == {:error, :not_enough_money}
    assert send("From", "To", 3, "USD") == {:ok, 0, 5}
  end

  test "user can not send money to himself" do
    assert create_user("Gary") == :ok
    assert send("Gary", "Gary", 1, "USD") == {:error, :sender_receiver_same}
  end
end
