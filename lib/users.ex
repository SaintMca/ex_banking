defmodule Users do
    def create(pid, name) do
        Agent.get_and_update(pid, fn users ->
            case users[name] do
                nil -> {:ok, addNewUser(users, name)}
                _ -> {:error, users}
            end
        end)
    end

    defp addNewUser(users, name) do
        users
        |> Map.put(
            name,
            %User{account: Account.create()}
        )
    end

    def getUser(pid, name) do
        Agent.get(pid, fn users ->
            case users[name] do
                nil -> :error
                _ -> :ok
            end
        end)
    end

   
    def getCurrentAgent() do
        case Agent.start_link(fn -> %{} end, name: :users) do
            {:ok, pid} -> pid
            {:error, {:already_started, pid}} -> pid
        end
    end
      
end