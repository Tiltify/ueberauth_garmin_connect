defmodule Ueberauth.Strategy.GarminConnect do
  @moduledoc """
  Garmin Connect Strategy for Überauth.
  """

  use Ueberauth.Strategy, uid_field: :userId, ignores_csrf_attack: true

  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra
  alias Ueberauth.Auth.Info
  alias Ueberauth.Strategy.GarminConnect.OAuth

  @doc """
  Handles initial request for Garmin Connect authentication
  """
  def handle_request!(conn) do
    token = OAuth.request_token!([])

    conn
    |> put_session(:garmin_connect_token, token)
    |> redirect!(OAuth.authorize_url!(token))
  end

  @doc """
  Handles the callback from Garmin Connect
  """
  def handle_callback!(%Plug.Conn{params: %{"oauth_verifier" => oauth_verifier}} = conn) do
    token = get_session(conn, :garmin_connect_token)

    case OAuth.access_token(token, oauth_verifier) do
      {:ok, access_token} -> fetch_user(conn, access_token)
      {:error, error} -> set_errors!(conn, [error("failed", error)])
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:garmin_connect_user, nil)
    |> put_session(:garmin_connect_token, nil)
  end

  @doc """
  Fetches the uid field from the user info response
  """
  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    conn.private.garmin_connect_user[uid_field]
  end

  @doc """
  Includes the credentials from the garmin_connect response.
  """
  def credentials(conn) do
    {token, secret} = conn.private.garmin_connect_token

    %Credentials{token: token, secret: secret}
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct. Garmin Connect
  does not have an endpoint to get user data, so this struct is empty.
  """
  def info(_conn) do
    %Info{}
  end

  @doc """
  Stores the raw information (including the token) obtained from the garmin_connect callback.
  """
  def extra(conn) do
    {token, _secret} = get_session(conn, :garmin_connect_token)

    %Extra{
      raw_info: %{
        token: token,
        user: conn.private.garmin_connect_user
      }
    }
  end

  defp fetch_user(conn, token) do
    case OAuth.get(:user_id, [], token) do
      {:ok, %{status_code: status_code, body: %{} = body, headers: _}}
      when status_code in 200..399 ->
        conn
        |> put_private(:garmin_connect_token, token)
        |> put_private(:garmin_connect_user, body)

      {:ok, %{status_code: status_code, body: body, headers: _}}
      when status_code in 200..399 and is_binary(body) ->
        body = Ueberauth.json_library().decode!(body)

        conn
        |> put_private(:garmin_connect_token, token)
        |> put_private(:garmin_connect_user, body)

      {:ok, %{status_code: _, body: body, headers: _}} ->
        set_errors!(conn, [error("failed", body)])
    end
  end

  defp option(conn, key) do
    default = Keyword.get(default_options(), key)

    conn
    |> options
    |> Keyword.get(key, default)
  end
end
