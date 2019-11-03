defmodule Todo do
  use Ecto.Schema

  schema "todos" do
    field :subject, :string
    belongs_to(:project, Project)

    timestamps()
  end
end
