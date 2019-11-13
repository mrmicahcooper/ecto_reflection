defmodule EctoReflection do
  import Enum, only: [map: 2]

  @moduledoc """
  Provides some conveniences to work with Queries and Schemas
  """

  @spec schemas(atom()) :: list(module())
  @doc """
  Return a list of all modules that `use` `Ecto.Schema` in the application.
  This is determined by checking if the `__schema__` function is defined on that module
  """
  def schemas(application) do
    {:ok, modules} = :application.get_key(application, :modules)
    for module <- modules, defines_schema?(module), do: module
  end

  @spec attributes(Ecto.Schema) :: list(atom())
  def attributes(module) do
    module.__struct__
    |> Map.keys()
    |> Kernel.--(~w[__meta__ __struct__]a)
  end

  @spec attributes(Ecto.Schema, :binary) :: list(binary())
  def attributes(module, :binary) do
    module
    |> attributes()
    |> map(&to_string/1)
  end

  @spec attribute?(Ecto.Schema, atom() | binary() ):: boolean()
  def attribute?(module, key) do
    to_string(key) in (attributes(module, :binary))
  end

  @spec fields(Ecto.Schema) :: list(atom())
  def fields(module) do
    module.__struct__
    |> Map.keys()
    |> Kernel.--(~w[__meta__ __struct__]a)
    |> Kernel.--(module.__schema__(:associations))
    |> Kernel.--(module.__schema__(:embeds))
  end

  @spec fields(Ecto.Schema, :binary) :: list(binary())
  def fields(module, :binary) do
    module
    |> fields()
    |> map(&to_string/1)
  end

  @spec field?(Ecto.Schema, atom() | binary()) :: boolean()
  def field?(module, key) do
    to_string(key) in fields(module, :binary)
  end

  def types(module) do
    module
    |> attributes()
    |> Enum.into(%{}, fn(key) -> {key, type(module, key)} end)
  end

  @spec type(Ecto.Schema, atom() | binary()) :: {atom(), atom() | module()} | {atom(), module(), module() | [atom()] }
  def type(module, key) when is_binary(key) do
    if attribute?(module, key) do
      type(module, String.to_atom(key))
    end
  end

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
  def source_fields(module) do
    module.__schema__(:fields)
  end

  @spec source_fields(Ecto.Schema, :binary) :: list(binary())
  def source_fields(module, :binary) do
    module
    |> source_fields()
    |> map(&to_string/1)
  end

  @spec source_field?(Ecto.Schema, atom() | binary()) :: boolean()
  def source_field?(module, key) do
    to_string(key) in source_fields(module, :binary)
  end

  @spec virtual_fields(Ecto.Schema) :: list(atom())
  def virtual_fields(module) do
    fields(module) -- source_fields(module)
  end

  @spec virtual_fields(Ecto.Schema, :binary) :: list(binary())
  def virtual_fields(module, :binary) do
    module
    |> virtual_fields()
    |> map(&to_string/1)
  end

  @spec virtual_field?(Ecto.Schema, atom() | binary()) :: boolean()
  def virtual_field?(module, key) do
    to_string(key) in virtual_fields(module, :binary)
  end

  @spec associations(Ecto.Schema) :: list(atom())
  def associations(module) do
    module.__schema__(:associations)
  end

  @spec associations(Ecto.Schema, :binary) :: list(binary())
  def associations(module, :binary) do
    module
    |> associations()
    |> map(&to_string/1)
  end

  @spec association?(Ecto.Schema, atom() | binary()) :: boolean()
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
