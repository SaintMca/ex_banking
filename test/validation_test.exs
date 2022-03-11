defmodule ValidationTest do
  use ExUnit.Case

  test "Money amount of any currency should not be negative" do
    assert Valdi.validate(-1, type: :integer, number: [min: 10, max: 999_999_999]) ==
             {:error, "must be greater than or equal to 10"}
  end

  test "Amount should be a number" do
    assert Valdi.validate("some string", type: :integer, number: [min: 10, max: 999_999_999]) ==
             {:error, "is not a integer"}
  end

  test "Username should be a string" do
    name = 1
    assert Valdi.validate_type(name, :string) == {:error, "is not a string"}
  end

  test "Currency should be a string" do
    currency = 1
    assert Valdi.validate_type(currency, :string) == {:error, "is not a string"}
  end
end
