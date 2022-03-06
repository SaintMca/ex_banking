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
end