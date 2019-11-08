defmodule EctoReflectionTest do
  use ExUnit.Case, async: true
  Application.ensure_started(:ecto_reflection)

  describe "schemas/1" do
    test "returns all the schemas in an application" do
      assert EctoReflection.schemas(:ecto_reflection) == [Address, AddressUser, Profile, Project, Todo, User]
    end
  end
end
