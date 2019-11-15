defmodule Foo do
  @moduledoc false
  use Ecto.Schema

  schema "foos" do
    field :bars
    field :bazes
    field :password, :string, virtual: true

    timestamps()
  end
end
