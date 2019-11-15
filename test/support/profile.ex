defmodule Profile do
  @moduledoc false
  use Ecto.Schema

  schema "profiles" do
    belongs_to(:user, User)
    field(:about, :map)

    timestamps()
  end
end
