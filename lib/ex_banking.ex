defmodule ExBanking do
 
  @spec create_user(user :: String.t) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(name) do
    pid = Users.getCurrentAgent();
    case Users.create(pid, name) do
      :error -> {:error, :user_already_exists}
                    :ok -> :ok
    end
  end

  @spec deposit(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(name, amount, currency) do
      
  end

  @spec withdraw(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :not_enough_money | :too_many_requests_to_user}
  def withdraw(name, amount, currency) do
      
  end

  @spec get_balance(user :: String.t, currency :: String.t) :: {:ok, balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(name, currency) do
    pid = Users.getCurrentAgent()
    case Users.getUser(pid, name) do
        :error -> {:error, :user_could_not_find}
        :ok ->
            case MemoryCache.create(pid, name) do
                :error -> IO.puts("ERROR")
                account ->
                    balance =  Account.get_balance(account, currency)
                    MemoryCache.delete(pid, name)
                    {:ok, balance}
            end
    end
  end

  @spec send(from_user :: String.t, to_user :: String.t, amount :: number, currency :: String.t) :: {:ok, from_user_balance :: number, to_user_balance :: number} | {:error, :wrong_arguments | :not_enough_money | :sender_does_not_exist | :receiver_does_not_exist | :too_many_requests_to_sender | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency) do
    
  end
end




