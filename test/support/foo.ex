defmodule Foo do
  use Ecto.Schema

  schema "foos" do
    field :bars
    field :bazes

    timestamps()
  end
end
