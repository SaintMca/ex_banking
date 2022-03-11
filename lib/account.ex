defmodule Account do
  def create() do
    {:ok, account} = Agent.start(fn -> %{} end)
    account
  end

  def get_balance(account, currency) do
    Agent.get(account, fn wallet ->
      balance(wallet, currency)
    end)
  end

  defp balance(wallet, currency) do
    if Map.has_key?(wallet, currency) do
      wallet[currency]
    else
      0
    end
  end

  def deposit(account, amount, currency) do
    Agent.get_and_update(account, fn wallet ->
      new_balance = balance(wallet, currency) + amount
      wallet = Map.put(wallet, currency, new_balance)
      {new_balance, wallet}
    end)
  end

  def withdraw(account, amount, currency) do
    Agent.get_and_update(account, fn wallet ->
      case balance(wallet, currency) - amount do
        new_balance when new_balance < 0 ->
          {:error, wallet}

        new_balance ->
          {new_balance, Map.put(wallet, currency, new_balance)}
      end
    end)
  end
end
