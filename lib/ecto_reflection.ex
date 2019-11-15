defmodule EctoReflection do
  import Enum, only: [map: 2]

  @moduledoc """
  Provides some conveniences to work with Queries and Schemas
  """

  @spec schemas(atom()) :: list(module())
  @doc """
  Return a list of all modules that use `Ecto.Schema` in the application.

  This is determined by checking if the `__schema__` function is defined on that module
  """
  def schemas(application) do
    {:ok, modules} = :application.get_key(application, :modules)
    for module <- modules, defines_schema?(module), do: module
  end

  @spec attributes(Ecto.Schema) :: list(atom())
  @doc """
  Return a list of attributes for an `Ecto.Schema`.

  If we have the following `Ecto.Schema`

  ```
  defmodule Foo do
    use Ecto.Schema

    schema "foos" do
      field :bars
      field :bazes

      timestamps()
    end
  end
  ```

  We can do:

  ```
  iex> EctoReflection.attributes(Foo)
  ~w[bars bazes id inserted_at password updated_at]a
  ```

  """
  def attributes(module) do
    module.__struct__
    |> Map.keys()
    |> Kernel.--(~w[__meta__ __struct__]a)
  end

  @spec attributes(Ecto.Schema, :binary) :: list(binary())
  @doc """
  Return a list of attributes as `binary()` for an `Ecto.Schema`

  ```
  iex> EctoReflection.attributes(Foo, :binary)
  ~w[bars bazes id inserted_at password updated_at]
  ```
  """
  def attributes(module, :binary) do
    module
    |> attributes()
    |> map(&to_string/1)
  end

  @spec attribute?(Ecto.Schema, atom() | binary() ):: boolean()
  @doc """
  Check if an attribute exists on an `Ecto.Schema`.

  ```
  iex> EctoReflection.attribute?(Foo, :bars)
  true

  iex> EctoReflection.attribute?(Foo, :non_attribute)
  false
  ```

  You can also safely use a binary to check:

  ```
  iex> EctoReflection.attribute?(Foo, "bars")
  true

  iex> EctoReflection.attribute?(Foo, "non_attribute")
  false
  ```
  """
  def attribute?(module, key) do
    to_string(key) in (attributes(module, :binary))
  end

  @spec fields(Ecto.Schema) :: list(atom())
  @doc """
  Return a list of fields (virtual or non virtual) defined in an `Ecto.Schema`

  ```
  iex> EctoReflection.fields(Foo)
  ~w[bars bazes id inserted_at password updated_at]a
  ```
  """
  def fields(module) do
    module.__struct__
    |> Map.keys()
    |> Kernel.--(~w[__meta__ __struct__]a)
    |> Kernel.--(module.__schema__(:associations))
    |> Kernel.--(module.__schema__(:embeds))
  end

  @spec fields(Ecto.Schema, :binary) :: list(binary())
  @doc """
  Return a list of fields as binaries (virtual or non virtual) defined in an `Ecto.Schema`

  ```
  iex> EctoReflection.fields(Foo)
  ~w[bars bazes id inserted_at password updated_at]a
  ```
  """
  def fields(module, :binary) do
    module
    |> fields()
    |> map(&to_string/1)
  end

  @spec field?(Ecto.Schema, atom() | binary()) :: boolean()
  @doc """
  Check if a field is defined on a schema

  ```
  iex> EctoReflection.field?(Foo, :bars)
  true

  iex> EctoReflection.field?(Foo, :non_field)
  false
  ```

  You can also safely pass in a binary

  ```
  iex> EctoReflection.field?(Foo, "bars")
  true

  iex> EctoReflection.field?(Foo, "non_field")
  false
  ```
  """
  def field?(module, key) do
    to_string(key) in fields(module, :binary)
  end

  @spec types(Ecto.Schema) :: map
  @doc """
  Return a map of the schema and its types as a convenient shorthand

  Say we have the following User `Ecto.Schema`

  ```
  defmodule User do
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
  ```

  Its types would look like this:

  ```
  iex> EctoReflection.types(User)
  %{
    addresses: {:many_to_many, Address, AddressUser},
    age: {:field, :integer},
    email: {:field, :string},
    id: {:field, :id},
    inserted_at: {:field, :naive_datetime},
    password: {:virtual_field, :string},
    password_digest: {:field, :string},
    profile: {:has_one, Profile},
    projects: {:has_many, Project},
    todos: {:has_many_through, Todo, [:projects, :todos]},
    updated_at: {:field, :naive_datetime},
    username: {:field, :string}
  }
  ```
  """
  def types(module) do
    module
    |> attributes()
    |> Enum.into(%{}, fn(key) -> {key, type(module, key)} end)
  end

  @spec type(Ecto.Schema, atom() | binary()) :: {atom(), atom() | module()} | {atom(), module(), module() | [atom()] }
  @doc """
  Return the type for a `Ecto.Schema`'s attribute

  ```
  iex> EctoReflection.type(User, "projects")
  {:has_many, Project}
  ```
  """
  def type(module, key) when is_binary(key) do
    if attribute?(module, key) do
      type(module, String.to_atom(key))
    end
  end

  @doc """
  Return the type for a `Ecto.Schema`'s attribute

  Accepts an atom or a binary for the attribute
  ```
  iex> EctoReflection.type(User, :projects)
  {:has_many, Project}
  ```
  """
  def type(schema, key) when is_atom(key) do
    with(
      nil <- schema.__schema__(:type, key),
      nil <- schema.__schema__(:association, key),
      nil <- schema.__schema__(:embed, key),
      type when not is_nil(type) <- schema.__changeset__ |> Map.get(key)
    ) do
      {:virtual, type}
    end
    |> data_type(schema)
  end

  @spec source_fields(Ecto.Schema) :: list(atom())
  @doc """
  Return a list of fields that to the database.

  In other words, all non-virtual fields
  ```
  iex> EctoReflection.source_fields(Foo)
  ~w[id bars bazes inserted_at updated_at]a
  ```
  """
  def source_fields(module) do
    module.__schema__(:fields)
  end

  @spec source_fields(Ecto.Schema, :binary) :: list(binary())
  @spec source_fields(Ecto.Schema) :: list(atom())
  @doc """
  Return a list of fields that to the database as binaries.

  In other words, all non-virtual fields
  ```
  iex> EctoReflection.source_fields(Foo, :binary)
  ~w[id bars bazes inserted_at updated_at]
  ```
  """
  def source_fields(module, :binary) do
    module
    |> source_fields()
    |> map(&to_string/1)
  end

  @spec source_field?(Ecto.Schema, atom() | binary()) :: boolean()
  @doc """
  Check if a non-virtual field is defined on a schema

  ```
  iex> EctoReflection.source_field?(Foo, :bars)
  true

  iex> EctoReflection.source_field?(Foo, :password)
  false
  ```

  Also safe with binaries

  ```
  iex> EctoReflection.source_field?(Foo, "bars")
  true

  iex> EctoReflection.source_field?(Foo, "password")
  false
  ```
  """
  def source_field?(module, key) do
    to_string(key) in source_fields(module, :binary)
  end

  @spec virtual_fields(Ecto.Schema) :: list(atom())
  @doc """
  Return a list of virtual fields defined on a schema

  ```
  iex> EctoReflection.virtual_fields(Foo)
  ~w[password]a
  ```
  """
  def virtual_fields(module) do
    fields(module) -- source_fields(module)
  end

  @spec virtual_fields(Ecto.Schema, :binary) :: list(binary())
  @doc """
  Return a list of virtual fields defined on a schema as binaries

  ```
  iex> EctoReflection.virtual_fields(Foo, :binary)
  ~w[password]
  ```
  """
  def virtual_fields(module, :binary) do
    module
    |> virtual_fields()
    |> map(&to_string/1)
  end

  @spec virtual_field?(Ecto.Schema, atom() | binary()) :: boolean()
  @doc """
  Check if the virtual field exists on the `Ecto.Schema`

  ```
  iex> EctoReflection.virtual_field?(Foo, :password)
  true

  iex> EctoReflection.virtual_field?(Foo, :bars)
  false
  ```

  Also works with binaries

  ```
  iex> EctoReflection.virtual_field?(Foo, "password")
  true

  iex> EctoReflection.virtual_field?(Foo, "bars")
  false
  ```
  """
  def virtual_field?(module, key) do
    to_string(key) in virtual_fields(module, :binary)
  end

  @spec associations(Ecto.Schema) :: list(atom())
  @doc """
  List all associations defined in a `Ecto.Schema`

  ```
  iex> EctoReflection.associations(User)
  ~w[profile addresses projects todos]a
  ```
  """
  def associations(module) do
    module.__schema__(:associations)
  end

  @spec associations(Ecto.Schema, :binary) :: list(binary())
  @doc """
  List all associations defined in a `Ecto.Schema` as binaries

  ```
  iex> EctoReflection.associations(User, :binary)
  ~w[profile addresses projects todos]
  ```
  """
  def associations(module, :binary) do
    module
    |> associations()
    |> map(&to_string/1)
  end

  @spec association?(Ecto.Schema, atom() | binary()) :: boolean()
  @doc """
  Check if the association is defined on the `Ecto.Schema`

  ```
  iex> EctoReflection.association?(User, :projects)
  true

  iex> EctoReflection.association?(User, :unassociated)
  false
  ```

  Also safe with binaries

  ```
  iex> EctoReflection.association?(User, "projects")
  true

  iex> EctoReflection.association?(User, "unassociated")
  false
  ```
  """
  def association?(module, key) do
    to_string(key) in associations(module, :binary)
  end

  @spec embeds(Ecto.Schema) :: list(atom())
  def embeds(module) do
    module.__schema__(:embeds)
  end

  @spec embeds(Ecto.Schema, :binary) :: list(binary())
  def embeds(module, :binary) do
    module
    |> embeds()
    |> map(&to_string/1)
  end

  @spec embed?(Ecto.Schema, atom() | binary()) :: boolean()
  def embed?(module, key) do
    to_string(key) in embeds(module, :binary)
  end

  @spec relationships(Ecto.Schema) :: list(atom())
  def relationships(module) do
    associations(module) ++ embeds(module)
  end

  @spec relationships(Ecto.Schema, :binary) :: list(binary())
  def relationships(module, :binary) do
    module
    |> relationships()
    |> map(&to_string/1)
  end

  @spec relationship?(Ecto.Schema, atom() | binary()) :: boolean()
  def relationship?(module, key) do
    to_string(key) in relationships(module, :binary)
  end

  @spec source_schema(Ecto.Query) :: Ecto.Schema
  def source_schema(query) do
    query.from.source |> elem(1)
  end

  defp defines_schema?(module) do
    Code.ensure_loaded(module)
    function_exported?(module, :__schema__, 1)
  end

  defp assoc_schema(schema, assoc) when is_atom(assoc) do
    case schema.__schema__(:association, assoc) do
      %{related: related} ->
        related

      %{through: [through, child_assoc]} ->
        through_schema = assoc_schema(schema, through)
        assoc_schema(through_schema, child_assoc)
    end
  end

  defp data_type(%Ecto.Association.Has{}=assoc, _) do
    assoc_type = "has_#{assoc.cardinality}" |> String.to_atom
    {assoc_type, assoc.related}
  end

  defp data_type(%Ecto.Association.HasThrough{}=assoc, schema) do
    assoc_type = "has_#{assoc.cardinality}_through" |> String.to_atom
    {assoc_type, assoc_schema(schema, assoc.field), assoc.through }
  end

  defp data_type(%Ecto.Association.BelongsTo{}=assoc, schema) do
    {:belongs_to, assoc_schema(schema, assoc.field)}
  end

  defp data_type(%Ecto.Association.ManyToMany{}=assoc, schema) do
    {:many_to_many, assoc_schema(schema, assoc.field), assoc.join_through, }
  end

  defp data_type(false, _), do: nil
  defp data_type({:virtual, type}, _), do: {:virtual_field, type}
  defp data_type(type, _), do: {:field, type}

end
