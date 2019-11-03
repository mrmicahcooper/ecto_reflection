# all schemas

schemas(:application | current_application())

Schema
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
