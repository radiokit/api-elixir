# RadioKit

Elixir API for RadioKit

Example usage:

```elixir
alias RadioKit.Data.Interface
alias RadioKit.Data.Query
alias RadioKit.Data.Changeset

# Query

query = %Query{
  select: ["id", "name", "record_repository", "stage"],
  join: ["record_repository"],
  where: [stage: [eq: "uploading"]],
  limit: "0,3",
  from: "data/record/file"}

{:ok, files} = Interface.all(query)

query = %Query{}
        |> Query.put_from("data/record/file")
        |> Query.append_select("id")
        |> Query.put_join("record_repository")
        |> Query.put_limit("1,2")
        |> Query.append_where([stage: [eq: "uploading"]])

{:ok, files} = Interface.all(query) # Default backend - :vault

# Different backend

{:ok, files} = Interface.all(query, :plumber)

# Insert

params = %{
  some: "params",
  to: "to add"
}

changeset = %Changeset{params: params, from: "data/record/file"}
{:ok, file} = Interface.insert(changeset)

# Different backend
{:ok, file} = Interface.insert(changeset, :plumber)

```

## Config


```elixir
config :radiokit_api,
       vault_base_url: "https://radiokit-vault-stag.herokuapp.com"
       plumber_base_url: "https://radiokit-plumber-stag.herokuapp.com"
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add radiokit_api to your list of dependencies in `mix.exs`:

        def deps do
          [{:radiokit_api, "~> 0.0.1"}]
        end

  2. Ensure radiokit_api is started before your application:

        def application do
          [applications: [:radiokit_api]]
        end
