defmodule Ueberauth.Strategy.GarminConnect.OAuth do
  @moduledoc """
  OAuth 1.0a for Garmin Connect

  Add `consumer_key` and `consumer_secret` to your configuration:

  config :ueberauth, Ueberauth.Strategy.GarminConnect.OAuth,
    consumer_key: System.get_env("GARMIN_CONNECT_CONSUMER_KEY"),
    consumer_secret: System.get_env("GARMIN_CONNECT_CONSUMER_SECRET")

  """

  alias Ueberauth.Strategy.GarminConnect.OAuth.Internal

  @defaults [
    access_token: "https://connectapi.garmin.com/oauth-service/oauth/access_token",
    authorize_url: "https://connect.garmin.com/oauthConfirm",
    request_token: "https://connectapi.garmin.com/oauth-service/oauth/request_token",
    user_id: "https://apis.garmin.com/wellness-api/rest/user/id"
  ]

  def access_token({token, token_secret}, verifier, opts \\ []) do
    opts
    |> client()
    |> to_url(:access_token)
    |> Internal.post([{"oauth_verifier", verifier}], consumer(client()), token, token_secret)
    |> decode_response()
  end

  def access_token!(access_token, verifier, opts \\ []) do
    case access_token(access_token, verifier, opts) do
      {:ok, token} -> token
      {:error, error} -> raise error
    end
  end

  def authorize_url!({token, _token_secret}, opts \\ []) do
    opts
    |> client()
    |> to_url(:authorize_url, %{"oauth_token" => token})
  end

  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, __MODULE__, [])

    @defaults
    |> Keyword.merge(config)
    |> Keyword.merge(opts)
    |> Enum.into(%{})
  end

  def get(url, access_token), do: get(url, [], access_token)

  def get(url, params, {token, token_secret}) do
    client()
    |> to_url(url)
    |> Internal.get(params, consumer(client()), token, token_secret)
  end

  def request_token(params \\ [], opts \\ []) do
    client = client(opts)

    client
    |> to_url(:request_token)
    |> Internal.get(params, consumer(client))
    |> decode_response()
  end

  def request_token!(params \\ [], opts \\ []) do
    case request_token(params, opts) do
      {:ok, token} -> token
      {:error, error} -> raise error
    end
  end

  defp consumer(client), do: {client.consumer_key, client.consumer_secret, :hmac_sha1}

  defp decode_response({:ok, %{status_code: 200, body: body}}) do
    params = Internal.params_decode(body)
    token = Internal.token(params)
    token_secret = Internal.token_secret(params)

    {:ok, {token, token_secret}}
  end

  defp decode_response({:ok, %{status_code: 401, body: body}}) do
    {:error, "401: #{inspect(body)}"}
  end

  defp decode_response({:ok, %{body: %{"errors" => [error | _]}}}) do
    {:error, "#{error["code"]} #{error["message"]}"}
  end

  defp decode_response({:error, %{reason: reason}}) do
    {:error, "#{reason}"}
  end

  defp decode_response(error) do
    {:error, error}
  end

  defp to_url(client, endpoint, params \\ nil) do
    endpoint = Map.get(client, endpoint, endpoint)

    if params,
      do: endpoint <> "?" <> URI.encode_query(params),
      else: endpoint
  end
end
