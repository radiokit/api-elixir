defmodule RadiokitEx.Query do
  defstruct select: [], join: [], from: "", where: [], limit: nil
  alias __MODULE__

  def put_limit(%Query{} = query, limit), do: put_in query.limit, limit
  def put_from(%Query{} = query, from), do: put_in query.from, from

  def append_select(%Query{} = query, select) when is_list(select) do
    update_in query.select, &(&1 ++ select )
  end
  def append_select(%Query{} = query, select), do: append_select(query, [select])

  def put_join(%Query{} = query, join) when is_list(join) do
    update_in query.join, &(&1 ++ join)
  end
  def put_join(%Query{} = query, join), do: put_join(query, [join])

  def append_where(%Query{} = query, condition) do
    update_in query.where, &(Keyword.merge(&1, condition, fn(k, v1, v2) -> v1 ++ v2 end))
  end
end
