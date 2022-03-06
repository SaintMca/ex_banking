defmodule Account do

    def create() do
        {:ok, account} = Agent.start(fn -> %{} end)
        account
    end

end