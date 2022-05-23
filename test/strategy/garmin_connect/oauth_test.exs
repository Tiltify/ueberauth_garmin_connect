defmodule Ueberauth.Strategy.GarminConnect.OAuthTest do
  use ExUnit.Case, async: true

  alias Ueberauth.Strategy.GarminConnect.OAuth

  setup do
    Application.put_env(:ueberauth, OAuth,
      consumer_key: "consumer_key",
      consumer_secret: "consumer_secret"
    )

    :ok
  end

  test "access_token!/2: raises an appropriate error on auth failure" do
    assert_raise RuntimeError, ~r/401/i, fn ->
      OAuth.access_token!({"badtoken", "badsecret"}, "badverifier")
    end
  end

  test "access_token!/2 raises an appropriate error on network failure" do
    assert_raise RuntimeError, ~r/nxdomain/i, fn ->
      OAuth.access_token!({"token", "secret"}, "verifier",
        access_token: "https://bogusapi.garmin.com"
      )
    end
  end

  test "request_token!/2: raises an appropriate error on auth failure" do
    assert_raise RuntimeError, ~r/401/i, fn ->
      OAuth.request_token!([], redirect_uri: "some/uri")
    end
  end

  test "request_token!/2: raises an appropriate error on network failure" do
    assert_raise RuntimeError, ~r/nxdomain/i, fn ->
      OAuth.request_token!([], request_token: "https://bogusapi.garminconnect.com")
    end
  end
end
