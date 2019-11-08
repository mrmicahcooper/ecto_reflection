defmodule EctoReflection do
  @moduledoc """
  Provides some conveniences to work with Queries and Schemas
  """

  def schemas(application) do
    {:ok, modules} = :application.get_key(application, :modules)
    for module <- modules, defines_schema?(module), do: module
  end

  defp defines_schema?(item) do
    Code.ensure_loaded(item)
    function_exported?(item, :__schema__, 1)
  end

  @spec source_schema(Ecto.Query) :: Ecto.Schema
  @doc """
  Find the source of an `Ecto.Query`
  """
  def source_schema(query) do
    query.from.source |> elem(1)
  end

  @spec schema_fields(Ecto.Schema) :: list(binary())
  @doc """
  Return all the fields of the passed in `Ecto.Schema`
  """
  def schema_fields(schema) do
    fields(schema) |> Enum.map(&to_string/1)
  end

  @spec fields(Ecto.Schema) :: list(atom())
  @doc """
  Return all the fields of the passed in `Ecto.Schema`
  """
  def fields(schema) do
    schema.__schema__(:fields)
  end

  @spec all_fields(Ecto.Schema) :: list(atom())
  @doc """
  Return all fields of the passed in `Ecto.Schema`
  This includes virtual fields
  """
  def all_fields(schema) do
    schema.__struct__
    |> Map.keys()
    |> Kernel.--(~w[__meta__ __struct__]a)
    |> Kernel.--(schema.__schema__(:associations))
    |> Kernel.--(schema.__schema__(:embeds))
  end

  @spec virtual_fields(Ecto.Schema) :: list(atom())
  @doc """
  Return all virtual fields of rhte passed in `Ecto.Schema`
  """
  def virtual_fields(schema) do
    all_fields(schema) -- fields(schema)
  end

  @spec has_field?(Ecto.Schema, :binary) :: :boolean
  @doc """
  Check if an `Ecto.Schema` has the passed in field
  """
  def has_field?(schema, field_name) when is_binary(field_name) do
    field_name in schema_fields(schema)
  end

  @spec field(Ecto.Schema, binary() | atom()) :: :atom | nil
  @doc """
  Get the `:atom` representation of a field if it exists in the passed in `Ecto.Schema`
  """
  def field(schema, field_name) when is_binary(field_name) do
    if has_field?(schema, field_name), do: String.to_atom(field_name)
  end

  def field(schema, field_name) when is_atom(field_name) do
    if field_name in schema.__schema__(:fields), do: field_name
  end

  @spec has_assoc?(Ecto.Schema, binary() | atom()) :: :boolean
  @doc """
  Check if an `Ecto.Schema` has the passed in association
  """
  def has_assoc?(schema, assoc_name) when is_binary(assoc_name) do
    list =
      schema.__schema__(:associations)
      |> Enum.map(&to_string/1)

    assoc_name in list
  end

  def has_assoc?(schema, assoc_name) when is_atom(assoc_name) do
    assoc_name in schema.__schema__(:associations)
  end

  @spec assoc_schema(Ecto.Schema, :binary) :: Ecto.Schema
  @doc """
  Return an associated schema
  """
  def assoc_schema(schema, assoc_name) when is_binary(assoc_name) do
    if has_assoc?(schema, assoc_name) do
      assoc = String.to_atom(assoc_name)

      case schema.__schema__(:association, assoc) do
        %{related: related} ->
          related

        %{through: [through, child_assoc]} ->
          through_schema = assoc_schema(schema, through)
          assoc_schema(through_schema, child_assoc)
      end
    end
  end

  def assoc_schema(schema, assoc) when is_atom(assoc) do
    case schema.__schema__(:association, assoc) do
      %{related: related} ->
        related

      %{through: [through, child_assoc]} ->
        through_schema = assoc_schema(schema, through)
        assoc_schema(through_schema, child_assoc)
    end
  end

end
