# Überauth Garmin Connect

> Garmin Connect strategy for Überauth.

## Installation

1. Setup your application at [Garmin Developers](http://garmin.com/en-US/forms/GarminConnectDeveloperAccess/).

2.  Add `:ueberauth_garmin_connect` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:ueberauth_garmin_connect, git: "git://github.com/tiltify/ueberauth_garmin_connect.git"}
      ]
    end
    ```

3.  Add Garmin to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        garmin_connect: {Ueberauth.Strategy.GarminConnect, []}
      ]
    ```

4.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.GarminConnect.OAuth,
      consumer_key: System.get_env("GARMIN_CONNECT_CONSUMER_KEY"),
      consumer_secret: System.get_env("GARMIN_CONNECT_CONSUMER_SECRET")
    ```

5.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

6.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

7. Your controller needs to implement callbacks to deal with `Ueberauth.Auth`
   and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initiate the request through:

    /auth/garmin_connect

## License

This library is released under the MIT License. See the [LICENSE](./LICENSE) file
for further details.
