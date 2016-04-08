# RadiokitEx

Elixir API for Radiokit vault

Example usage:

    alias RadiokitEx.Repo
    alias RadiokitEx.Query

    query = %Query{
      select: ["id", "name", "record_repository", "stage"],
      join: ["record_repository"],
      where: [stage: [eq: "uploading"]],
      limit: "0,3",
      from: "data/record/file"}

    {:ok, files} = Repo.all(query)

    query = %Query{}
            |> Query.put_from("data/record/file")
            |> Query.append_select("id")
            |> Query.put_join("record_repository")
            |> Query.put_limit("1,2")
            |> Query.append_where([stage: [eq: "uploading"]])

    {:ok, files} = Repo.all(query)


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add radiokit_exvault to your list of dependencies in `mix.exs`:

        def deps do
          [{:radiokit_exvault, "~> 0.0.1"}]
        end

  2. Ensure radiokit_exvault is started before your application:

        def application do
          [applications: [:radiokit_exvault]]
        end
