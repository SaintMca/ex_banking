defmodule ExBanking do
  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(name) do
    case Valdi.validate_type(name, :string) do
      :error ->
        {:error, :wrong_arguments}

      :ok ->
        pid = Users.getCurrentAgent()

        case Users.create(pid, name) do
          :error -> {:error, :user_already_exists}
          :ok -> :ok
        end
    end
  end

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(name, amount, currency) do
    case Valdi.validate_type(name, :string) && Valdi.validate_type(currency, :string) &&
           Valdi.validate(amount, type: :number, number: [min: 0, max: 999_999_999]) do
      :error ->
        {:error, :wrong_arguments}

      :ok ->
        pid = Users.getCurrentAgent()

        amount
        |> Decimal.new()
        # 2 precision required on amount
        |> Decimal.round(2)

        case Users.getUser(pid, name) do
          :error ->
            {:error, :user_does_not_exist}

          :ok ->
            case InMemory.create(pid, name) do
              :error ->
                {:error, :too_many_requests_to_user}

              account ->
                new_balance = Account.deposit(account, amount, currency)
                InMemory.delete(pid, name)
                {:ok, new_balance}
            end
        end
    end
  end

  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(name, amount, currency) do
    case Valdi.validate_type(name, :string) && Valdi.validate_type(currency, :string) &&
           Valdi.validate(amount, type: :number, number: [min: 0, max: 999_999_999]) do
      :error ->
        {:error, :wrong_arguments}

      :ok ->
        pid = Users.getCurrentAgent()

        amount
        |> Decimal.new()
        # 2 precision required on amount
        |> Decimal.round(2)

        case Users.getUser(pid, name) do
          :error ->
            {:error, :user_does_not_exist}

          :ok ->
            case InMemory.create(pid, name) do
              :error ->
                {:error, :too_many_requests_to_user}

              account ->
                new_balance = Account.withdraw(account, amount, currency)
                InMemory.delete(pid, name)

                case new_balance do
                  :error -> {:error, :not_enough_money}
                  new_balance -> {:ok, new_balance}
                end
            end
        end
    end
  end

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(name, currency) do
    case Valdi.validate_type(name, :string) &&
           Valdi.validate_type(currency, :string) do
      :error ->
        {:error, :wrong_arguments}

      :ok ->
        pid = Users.getCurrentAgent()

        case Users.getUser(pid, name) do
          :error ->
            {:error, :user_does_not_exist}

          :ok ->
            case InMemory.create(pid, name) do
              :error ->
                {:error, :too_many_requests_to_user}

              account ->
                balance = Account.get_balance(account, currency)
                InMemory.delete(pid, name)
                {:ok, balance}
            end
        end
    end
  end

  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) ::
          {:ok, from_user_balance :: number, to_user_balance :: number}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver
             | :sender_receiver_same}
  def send(from_user, to_user, amount, currency) do
    case Valdi.validate_type(to_user, :string) && Valdi.validate_type(from_user, :string) do
      :error ->
        {:error, :wrong_arguments}

      :ok ->
        pid = Users.getCurrentAgent()

        case Users.getUser(pid, from_user) do
          :error ->
            {:error, :sender_does_not_exist}

          :ok ->
            case from_user != to_user do
              true ->
                case Users.getUser(pid, to_user) do
                  :error ->
                    {:error, :receiver_does_not_exist}

                  :ok ->
                    case InMemory.create(pid, from_user) do
                      :error ->
                        {:error, :too_many_requests_to_sender}

                      from_account ->
                        case InMemory.create(pid, to_user) do
                          :error ->
                            InMemory.delete(pid, from_user)
                            {:error, :too_many_requests_to_receiver}

                          to_account ->
                            case Account.withdraw(from_account, amount, currency) do
                              :error ->
                                InMemory.delete(pid, from_user)
                                InMemory.delete(pid, to_user)
                                {:error, :not_enough_money}

                              from_user_balance ->
                                to_user_balance = Account.deposit(to_account, amount, currency)
                                InMemory.delete(pid, from_user)
                                InMemory.delete(pid, to_user)
                                {:ok, from_user_balance, to_user_balance}
                            end
                        end
                    end
                end

              false ->
                {:error, :sender_receiver_same}
            end
        end
    end
  end
end
