# all schemas

schemas(:application | current_application())

Schema
fields()

source_fields()
virtual_fields

reflection() - all the things()

fields(schema) :: [atom()]
field(schema, :field | "field") :: nil | :field
field_type(schema, :field) :: nil | :type
has_field?(schema, :field || "field") :: boolean()
primary_key(schema) :: [:id, :id]
id(schema) :: id | "id"
source(schema) :: "source"

associations(schema) :: [:assoc_name, Assoc, cardinality]
associated_schemas(schema) :: [{:assoc_name, Assoc}]
embeds(schema) :: [:assoc_name, Assoc, cardinality]
embedded_schemas(schema) :: [{:assoc_name, Assoc}]
has_association?(:schema, :association | "association") :: boolean()
associated_schema(schema, :assoc_name | "assoc_name") :: schema
association(schema, :assoc_name | "assoc_name") :: {schema, cardinality}

Query

source_schema

.attributes(schema, as: :binary) - everthing from the struct (minus private stuff)
.attributes(schema) - everthing from the struct (minus private stuff)
.attribute?(schema, "attribute" | :attribute)
~.attribute(schema, "attribute" | :attribute)

.source_fields - all non virtual fields
.source_field?()
.source_field()

.virtual_fields - all virtual fields
.virtual_field?()
.virtual_field()

.fields - virtual + non virtual fields
.field?
.field()

.associations - all associations
.association?()
.association()

.embeds - all embeds
.embed?()
.embed()

.relationships() - all assocations + all embeds
.relationship?()
.relationship()


.type %EctoReflection.Attribute{
  name: "",
  source: nil or field source,
  type: "has_many", "belongs_to", "map"
  virtual: :boolean,
  related: module (User, etc...)
}
