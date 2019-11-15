defmodule Project do
  @moduledoc false
  use Ecto.Schema

  schema "projects" do
    field(:name)
    field(:description)
    has_many(:todos, Todo)
    belongs_to(:user, User)

    timestamps()
  end
end
