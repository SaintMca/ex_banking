defmodule LimitChecker do
  @maxLoad 10
  def get_max_load() do
    @maxLoad
  end

  def check(load) do
    if load < @maxLoad do
      :ok
    else
      :error
    end
  end
end
