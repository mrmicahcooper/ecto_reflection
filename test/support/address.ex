defmodule Address do
  @moduledoc false
  use Ecto.Schema


  schema "address" do
    field :address1, :string
    field :address2, :string
    field :city, :string
    field :state, :string
    field :zipcode, :string

    belongs_to(:address_user, AddressUser)

    timestamps()
  end
end
