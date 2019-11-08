defmodule EctoReflectionTest do
  use ExUnit.Case, async: true
  import Ecto.Query
  doctest EctoReflection

  describe "schemas/1" do
    test "returns all the schemas in an application" do
      assert EctoReflection.schemas(:ecto_reflection) == [Address, AddressUser, Profile, Project, Todo, User]
    end
  end

  describe "schema_fields/1" do
    test "return string representations of a schema's fields" do
      assert EctoReflection.schema_fields(User) == ~w[id username email age password_digest]
    end
  end

  describe "all_fields/1" do
    test "return all fields (virtual or not)" do
      assert EctoReflection.all_fields(User) == ~w[age email id password password_digest username]a
    end
  end

  describe "fields/1" do
    test "return all the non-virtual fields in a schema" do
      assert EctoReflection.fields(User) == ~w[id username email age password_digest]a
    end
  end

  describe "virtual_fields/1" do
    test "returns all virtual fields in a schema" do
      assert EctoReflection.virtual_fields(User) == ~w[password]a
    end
  end

  describe "has_field?/2" do
    test "existing field returns true" do
      assert EctoReflection.has_field?(User, "email") == true
    end

    test "non existing field returns true" do
      assert EctoReflection.has_field?(User, "x") == false
    end
  end

  describe "field/2" do
    test "returns field if it exists in the schema" do
      assert EctoReflection.field(User, "username") == :username
    end

    test "returns nil if the field doesn't exist" do
      assert EctoReflection.field(User, "noop") == nil
    end

    test "returns the field with a passed in atom" do
      assert EctoReflection.field(User, :username) == :username
    end
  end

  describe "has_assoc?/2" do
    test "existing assoc returns true", _ do
      assert EctoReflection.has_assoc?(User, "projects") == true
    end

    test "existing assoc returns true with atom", _ do
      assert EctoReflection.has_assoc?(User, :projects) == true
    end

    test "non existing assoc returns false", _ do
      assert EctoReflection.has_assoc?(User, "bazes") == false
    end
  end

  describe "assoc_schema/2" do
    test "returns the associated schema if present" do
      assert EctoReflection.assoc_schema(User, "projects") == Project
    end

    test "getting the schema with an atom" do
      assert EctoReflection.assoc_schema(User, :projects) == Project
    end

    test "returns the associated schema from a `through` if present" do
      assert EctoReflection.assoc_schema(User, "todos") == Todo
    end

    test "returns nil associated schema if absent" do
      assert EctoReflection.assoc_schema(User, "bazes") == nil
    end
  end

  describe "source_schema/1" do
    test "returns the source schema from a query" do
      query = from(user in User)

      assert EctoReflection.source_schema(query) == User
    end
  end
end
