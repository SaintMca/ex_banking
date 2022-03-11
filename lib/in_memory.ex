defmodule InMemory do
  def create(pid, name) do
    Agent.get_and_update(pid, fn users ->
      user = users[name]
      requestCount = user.requestCount

      case LimitChecker.check(requestCount) do
        :error ->
          {:error, users}

        :ok ->
          user = Map.put(user, :requestCount, requestCount + 1)
          users = Map.put(users, name, user)
          {user.account, users}
      end
    end)
  end

  def delete(pid, name) do
    Agent.update(pid, fn users ->
      user = users[name]
      user = Map.put(user, :requestCount, user.requestCount - 1)
      Map.put(users, name, user)
    end)
  end
end
