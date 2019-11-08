defmodule EctoReflection do

  def schemas(application) do
    {:ok, modules} = :application.get_key(application, :modules)
    for module <- modules, defines_schema?(module), do: module
  end

  def defines_schema?(item) do
    Code.ensure_loaded(item)
    function_exported?(item, :__schema__, 1)
  end

end
