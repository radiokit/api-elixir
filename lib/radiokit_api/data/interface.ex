defmodule RadioKit.Data.Interface do
  alias RadioKit.Data.Query
  alias RadioKit.Data.Changeset
  alias RadioKit.Data.Params
  require Logger

  @timeout 1_000 * 100
  @request_options [timeout: @timeout, recv_timeout: @timeout, follow_redirect: false]

  def default_headers do
    # TODO: srlsy, change it
    [{"Authorization", "Bearer " <> "LolThisCantBeRight"}]
  end

  def all(query, backend, headers \\ [], options \\ []) do
    %Query{select: select, from: from, join: join, where: where, limit: limit, scope: scope, order: order} = query
    params = Params.encode_params(a: select, j: join, c: where, l: limit, s: scope, o: order)
    location = backend_base(backend) <> from <> "?" <> params
    headers = headers ++ default_headers()

    Logger.debug("[#{__MODULE__} #{inspect(self())}] Requesting #{location}, headers = #{inspect(headers)}, options = #{inspect(options)}")
    HTTPoison.get(location, headers, options) |> handle_query_response
  end


  def delete(changeset, backend) when is_atom(backend) do
    delete(changeset, default_headers(), backend)
  end
  def delete(
    %Changeset{params: %{id: id}, from: from},
    authorization_header \\ default_headers(),
    backend \\ :vault)
  do
    location = backend_base(backend) <> from <> "/" <> id
    headers = authorization_header ++ [{"Content-Type", "application/json"}]
    HTTPoison.request(:delete, location, "", headers, @request_options) |> handle_delete_response
  end

  def insert(changeset, backend) when is_atom(backend) do
    insert(changeset, default_headers(), backend)
  end
  def insert(
    %Changeset{params: params, from: from},
    authorization_header \\ default_headers(),
    backend \\ :vault)
  do
    location = backend_base(backend) <> from
    body = Poison.encode!(params)
    headers = authorization_header ++ [{"Content-Type", "application/json"}]
    HTTPoison.request(:post, location, body, headers, @request_options) |> handle_insert_response
  end

  def handle_delete_response({:ok, %HTTPoison.Response{status_code: 401, body: body}}), do: {:error, "Unauthorized", body}
  def handle_delete_response({:ok, %HTTPoison.Response{status_code: 422, body: body}}), do: {:error, "Unprocessable entity", body }
  def handle_delete_response({:ok, %HTTPoison.Response{status_code: 500, body: body}}), do: {:error, "Server error", body}
  def handle_delete_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    case Poison.decode(body) do
      {:ok, decoded_body} -> {:ok, decoded_body["data"]}
      _ -> {:error, "Invalid Response", body}
    end
  end
  def handle_delete_response(any), do: {:error, "Invalid response", any}

  def handle_query_response({:ok, %HTTPoison.Response{status_code: 401, body: body}}), do: {:error, "Unauthorized", body}
  def handle_query_response({:ok, %HTTPoison.Response{status_code: 422, body: body}}), do: {:error, "Unprocessable entity", body }
  def handle_query_response({:ok, %HTTPoison.Response{status_code: 500, body: body}}), do: {:error, "Server error", body}
  def handle_query_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    case Poison.decode(body) do
      {:ok, decoded_body} -> {:ok, decoded_body["data"]}
      _ -> {:error, "Invalid Response", body}
    end
  end
  def handle_query_response(any), do: {:error, "Invalid response", any}

  def handle_insert_response({:ok, %HTTPoison.Response{status_code: 401, body: body}}), do: {:error, "Unauthorized", body}
  def handle_insert_response({:ok, %HTTPoison.Response{status_code: 422, body: body}}), do: {:error, "Unprocessable entity", body }
  def handle_insert_response({:ok, %HTTPoison.Response{status_code: 500, body: body}}), do: {:error, "Server error", body}
  def handle_insert_response({:ok, %HTTPoison.Response{status_code: 201, body: body}}) do
    case Poison.decode(body) do
      {:ok, decoded_body} -> {:ok, decoded_body["data"]}
      _ -> {:error, "Invalid Response", body}
    end
  end
  def handle_insert_response(any), do: {:error, "Invalid response", any}


  defp backend_base(backend) do
    env_key = "#{backend}_base_url" |> String.to_atom

    case Application.get_env(:radiokit_api, env_key) do
      nil ->
        throw """
        Unable to find config for the #{inspect(backend)} RadioKit backend.

        Please add

          config :radiokit_api,
            #{backend}_base_url: "https://#{backend}.radiokitapp-stag.org"

        to your config/config.exs and

        config :radiokit_api,
          #{backend}_base_url: "https://#{backend}.radiokitapp.org"

        to your config/prod.exs.
        """

      {:system, var} ->
        case System.get_env(var) do
          nil ->
            throw """
            Unable to determine base URL for the #{inspect(backend)} RadioKit backend.

            Your config/config.exs specifies to fetch it from the #{inspect(var)}
            environment variable but it is unset.
            """

          base_url ->
            base_url <> "/api/rest/v1.0/"
        end

      base_url ->
        base_url <> "/api/rest/v1.0/"
    end
  end
end
