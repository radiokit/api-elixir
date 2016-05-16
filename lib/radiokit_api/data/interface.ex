defmodule RadioKit.Data.Interface do
  alias RadioKit.Data.Query
  alias RadioKit.Data.Changeset
  alias RadioKit.Data.Params

  @timeout 1_000 * 100
  @request_options [timeout: @timeout, recv_timeout: @timeout, follow_redirect: false]

  def default_headers do
    # TODO: srlsy, change it
    [{"Authorization", "Bearer " <> "LolThisCantBeRight"}]
  end

  def backend_base(:vault), do: Application.get_env(:radiokit_api, :vault_base_url) <> "/api/rest/v1.0/"
  def backend_base(:plumber), do: Application.get_env(:radiokit_api, :plumber_base_url) <> "/api/rest/v1.0/"

  def all(query, backend) when is_atom(backend) do
    all(query, default_headers, backend)
  end
  def all(
    %Query{select: select, from: from, join: join, where: where, limit: limit},
    authorization_header \\ default_headers,
    backend \\ :vault)
  do
    query = Params.encode_params(a: select, j: join, c: where, l: limit)
    location = backend_base(backend) <> from <> "?" <> query
    HTTPoison.get(location, authorization_header) |> handle_query_response
  end

  def insert(changeset, backend) when is_atom(backend) do
    insert(changeset, default_headers, backend)
  end
  def insert(
    %Changeset{params: params, from: from},
    authorization_header \\ default_headers,
    backend \\ :vault)
  do
    location = backend_base(backend) <> from
    body = Poison.encode!(params)
    headers = authorization_header ++ [{"Content-Type", "application/json"}]
    HTTPoison.request(:post, location, body, headers, @request_options) |> handle_insert_response
  end

  def handle_query_response({:ok, %HTTPoison.Response{status_code: 401, body: body}}), do: {:error, "Unauthorized", body}
  def handle_query_response({:ok, %HTTPoison.Response{status_code: 422, body: body}}), do: {:error, "Unprocessable entity", body }
  def handle_query_response({:ok, %HTTPoison.Response{status_code: 500, body: body}}), do: {:error, "Server error", body}
  def handle_query_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    case Poison.decode(body) do
      {:ok, decoded_body} -> {:ok, decoded_body["data"]}
      _ -> {:error, "Invalid Response", body}
    end
  end

  # TODO: handle this
  def handle_query_response(any), do: any

  def handle_insert_response({:ok, %HTTPoison.Response{status_code: 401, body: body}}), do: {:error, "Unauthorized", body}
  def handle_insert_response({:ok, %HTTPoison.Response{status_code: 422, body: body}}), do: {:error, "Unprocessable entity", body }
  def handle_insert_response({:ok, %HTTPoison.Response{status_code: 500, body: body}}), do: {:error, "Server error", body}
  def handle_insert_response({:ok, %HTTPoison.Response{status_code: 201, body: body}}) do
    case Poison.decode(body) do
      {:ok, decoded_body} -> {:ok, decoded_body["data"]}
      _ -> {:error, "Invalid Response", body}
    end
  end

  # TODO: handle this
  def handle_insert_response(any), do: any
end
