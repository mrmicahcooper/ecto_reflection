defmodule EctoReflectionTest do
  use ExUnit.Case, async: true
  import Ecto.Query
  doctest EctoReflection

  describe "schemas/1" do
    test "returns all the schemas in an application" do
      assert EctoReflection.schemas(:ecto_reflection) == [Address, AddressUser, Profile, Project, Todo, User]
    end
  end

  describe "attributes/1" do
    test "return all attributes (virtual or not)" do
      assert EctoReflection.attributes(User) == [
        :address_users,
        :addresses,
        :age,
        :email,
        :id,
        :inserted_at,
        :password,
        :password_digest,
        :profile,
        :projects,
        :todos,
        :updated_at,
        :username
      ]
    end
  end

  describe "attribute?/2" do
    test "existing field returns true" do
      assert EctoReflection.attribute?(User, "email") == true
    end

    test "non existing field returns true" do
      assert EctoReflection.attribute?(User, "x") == false
    end
  end

  describe "source_fields/1" do
    test "return all the non-virtual fields in a schema" do
      assert EctoReflection.source_fields(User) == ~w[id username email age password_digest inserted_at updated_at]a
    end
  end

  describe "source_field?/1" do
    test "existing field that maps to a database returns true" do
      assert EctoReflection.source_field?(User, "password_digest") == true
    end

    test "virtual field returns false" do
      assert EctoReflection.source_field?(User, "password") == false
    end
  end

  describe "virtual_fields/1" do
    test "returns all virtual fields in a schema" do
      assert EctoReflection.virtual_fields(User) == ~w[password]a
    end
  end

  describe "field?/2" do
    test "existing field returns true" do
      assert EctoReflection.field?(User, "email") == true
    end

    test "non existing field returns true" do
      assert EctoReflection.field?(User, "projects") == false
      assert EctoReflection.field?(User, "z") == false
    end
  end

  describe "association?/2" do
    test "existing assoc returns true" do
      assert EctoReflection.association?(User, "projects") == true
    end

    test "existing assoc returns true with atom" do
      assert EctoReflection.association?(User, :projects) == true
    end

    test "non existing assoc returns false" do
      assert EctoReflection.association?(User, "bazes") == false
    end
  end

  describe "type/2" do
    test "returns the data type for a field" do
      assert EctoReflection.type(User, "email") == {:field, :string}
    end

    test "returns the data type for a virtual field" do
      assert EctoReflection.type(User, "password") == {:field, {:virtual, :string}}
    end

    test "returns the data type for a has_many association" do
      assert EctoReflection.type(User, "projects") == {:has_many, Project}
    end

    test "returns the data type for a has_many_through association" do
      assert EctoReflection.type(User, "todos") == {:has_many_through, [:projects, :todos], Todo}
    end

    test "returns the data type for a belongs_to" do
      assert EctoReflection.type(Project, "user") == {:belongs_to, User}
    end

    test "returns nil if attribute doesnt exist" do
      assert EctoReflection.type(User, "foobar") == nil
    end
  end

  describe "source_schema/1" do
    test "returns the source schema from a query" do
      query = from(user in User)

      assert EctoReflection.source_schema(query) == User
    end
  end
end
