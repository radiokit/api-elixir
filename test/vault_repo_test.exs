defmodule RadioKit.Data.QuerySpec do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias RadioKit.Data.Interface
  alias RadioKit.Data.Query

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  test "query is modifiable" do
    query = %Query{}
    expected_query = %Query{
      select: ["a", "b", "c"],
      from: "some/path",
      join: ["d", "e"],
      limit: "1,2",
      where: [a: [b: 1, c: 3]]
    }

    chained_query = query
                    |> Query.append_select("a")
                    |> Query.append_select(["b", "c"])
                    |> Query.put_from("some/path")
                    |> Query.put_join("d")
                    |> Query.put_join("e")
                    |> Query.put_limit("1,2")
                    |> Query.append_where([a: [b: 1]])
                    |> Query.append_where([a: [c: 3]])

    assert chained_query == expected_query
  end

  setup do
    expected_first_file = %{"id" => "fb9994b3-df3d-4fd9-a34c-0c6981023329",
     "name" => "Still_the_Mind.mp3",
     "record_repository" => %{
       "destroy_at" => nil,
       "extra" => nil,
       "files_count" => 35,
       "files_size_total" => 62180055,
       "id" => "75a40562-cf42-4436-a049-f2f23ec903aa",
       "inserted_at" => "2015-12-22T18:25:42Z",
       "name" => "zenek",
       "references" => %{
         "user_account_id" => "b7c43b05-b38a-44c3-a65a-0d3986e1b62c"},
       "updated_at" => "2015-12-22T18:25:42Z"},
     "stage" => "uploading"}

   query = %Query{
     select: ["id", "name", "record_repository", "stage"],
     join: ["record_repository"],
     where: [stage: [eq: "uploading"]],
     limit: "0,3",
     from: "data/record/file"}

   {:ok, expected_first_file: expected_first_file, query: query}
  end

  test "#all requests all files from vault matching query", context do
    use_cassette "data_record_file_200" do
      {:ok, files} = Interface.all(context[:query])
      assert length(files) == 3
      assert hd(files) == context[:expected_first_file]
    end
  end
end
