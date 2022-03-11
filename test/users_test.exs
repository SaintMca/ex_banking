defmodule UsersTest do
  use ExUnit.Case, async: true

  def agent() do
    case Agent.start_link(fn -> %{} end, name: :users) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  setup do
    %{pid: agent()}
  end

  test "create new user", %{pid: pid} do
    assert Users.create(pid, "Melih") == :ok
  end

  test "user already exists", %{pid: pid} do
    assert Users.create(pid, "Can") == :ok
    assert Users.create(pid, "Can") == :error
  end
end
