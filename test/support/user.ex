defmodule User do
  @moduledoc false
  use Ecto.Schema

  schema "users" do
    field(:username, :string)
    field(:email, :string)
    field(:age, :integer)
    field(:password, :string, virtual: true)
    field(:password_digest, :string)
    has_one(:profile, Profile)
    many_to_many(:addresses, Address, join_through:  AddressUser)
    has_many(:projects, Project)
    has_many(:todos, through: [:projects, :todos])

    timestamps()
  end
end
