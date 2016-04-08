defmodule RadiokitEx.Repo do
  alias RadiokitEx.Query

  @vault_base_url "https://radiokit-vault-stag.herokuapp.com/api/rest/v1.0/"

  def default_headers do
    # TODO: srlsy, change it
    [{"Authorization", "Bearer " <> "LolThisCantBeRight"}]
  end

  def all(%Query{select: select, from: from, join: join, where: where, limit: limit}, authorization_header \\ default_headers) do
    query = encode_params(a: select, j: join, c: where, l: limit)

    HTTPoison.get(@vault_base_url <> from <> "?" <> query, authorization_header)
    |> handle_response
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 401}}), do: {:error, "Unauthorized"}
  def handle_response({:ok, %HTTPoison.Response{status_code: 422, body: body}}), do: {:error, "Unprocessable entity", body }
  def handle_response({:ok, %HTTPoison.Response{status_code: 500, body: body}}), do: {:error, "Server error", body}
  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    case Poison.decode(body) do
      {:ok, decoded_body} -> {:ok, decoded_body["data"]}
      _ -> {:error, "Invalid Response", body}
    end
  end

  # TODO: handle this
  def handle_response(any), do: any

  def encode_params({key, elements}) when is_list(elements) do
    Enum.map_join(elements, "&", &encode_param(&1, key))
  end

  def encode_params({key, value}) when not is_nil(value) do
    URI.encode("#{key}=#{value}")
  end

  def encode_params(keywords) when is_list(keywords) do
    Enum.map_join(keywords, "&", &encode_params/1)
  end

  def encode_params(_other), do: ""

  def encode_param({inner_key, params}, key) when is_list(params) do
    Enum.map_join(params, "&", fn({inner_inner_key, value}) ->
      URI.encode("#{key}[#{inner_key}][]=#{inner_inner_key} #{value}")
    end)
  end

  def encode_param(param, key) do
    URI.encode("#{key}[]=#{param}")
  end
end
