defmodule AddressUser do
  use Ecto.Schema

  schema "address_users" do
    belongs_to(:user, User)
    belongs_to(:address, Address)

    timestamps()
  end
end
