defmodule Hub88Wallet.Users.UsersTest do
  use Hub88Wallet.DataCase

  alias Hub88Wallet.Users.Users
  alias Hub88Wallet.Users.User

  describe "get_or_create_user_by_name/1" do
    test "creates a new user if one does not exist" do
      user_name = "new_user"
      assert {:ok, user} = Users.get_or_create_user_by_name(user_name)
      assert user.user == user_name
      assert user.balance == 1000 * 100000
      assert user.currency == "EUR"
    end

    test "returns the existing user if one exists" do
      user_name = "existing_user"
      {:ok, _user} = Users.create_user(user_name)

      assert {:ok, user} = Users.get_or_create_user_by_name(user_name)
      assert user.user == user_name
    end
  end

  describe "get_user_by_name/1" do
    test "returns nil if user does not exist" do
      assert Users.get_user_by_name("non_existent_user") == nil
    end

    test "returns the user if it exists" do
      user_name = "existing_user"
      {:ok, _user} = Users.create_user(user_name)

      assert %User{user: ^user_name} = Users.get_user_by_name(user_name)
    end
  end

  describe "create_user/1" do
    test "creates a user with default balance and currency" do
      user_name = "new_user"
      assert {:ok, user} = Users.create_user(user_name)
      assert user.user == user_name
      assert user.balance == 1000 * 100000
      assert user.currency == "EUR"
    end

    test "fails if the user already exists" do
      user_name = "existing_user"
      {:ok, _user} = Users.create_user(user_name)

      assert {:error, _changeset} = Users.create_user(user_name)
    end
  end
end
