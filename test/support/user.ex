defmodule User do
  use Ecto.Schema

  schema "users" do
    field(:username, :string)
    field(:email, :string)
    field(:age, :integer)
    field(:password, :string, virtual: true)
    field(:password_digest, :string)
    has_one(:profile, Profile)
    has_many(:address_users, AddressUser)
    has_many(:addresses, through: [:address_users, :address])
    has_many(:projects, Project)
    has_many(:todos, through: [:projects, :todos])

    timestamps()
  end
end
