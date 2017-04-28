defmodule Gobstopper.API.Auth.Email do
    @moduledoc """
      Handles the management of email authorization credentials.
    """

    @service Gobstopper.Service.Auth
    @credential_type :email

    alias Gobstopper.API.Auth

    @doc """
      Create a new identity initially associated with the given email credential.

      Returns the session token on successful creation. Otherwise returns an
      error.
    """
    @spec register(String.t, String.t) :: { :ok, Auth.token } | { :error, String.t }
    def register(email, pass), do: GenServer.call(@service, { :create, { @credential_type, { email, pass } } })

    @doc """
      Get the current email credential associated with the identity.

      Returns the state of the credential if one exists or does not exist. Otherwise
      returns an error.
    """
    @spec get(Auth.token) :: { :ok, { :unverified | :verified, String.t } | { :none, nil } } | { :error, String.t }
    def get(token) do
        case GenServer.call(@service, { :all_credentials, token }) do
            { :ok, credentials } -> credentials[@credential_type]
            error -> error
        end
    end

    @doc """
      Associate an email credential with the identity, replacing the old email
      credential.

      Returns `:ok` on successful creation. Otherwise returns an error.
    """
    @spec set(Auth.token, String.t, String.t) :: :ok | { :error, String.t }
    def set(token, email, pass) do
        credential = { @credential_type, { email, pass } }

        with { :error, _update_error } <- GenServer.call(@service, { :update, credential, token }),
             { :error, create_error } <- GenServer.call(@service, { :create, credential, token }) do
                { :error, create_error }
        else
            :ok -> :ok
        end
    end

    @doc """
      Remove the email credential associated with the identity.

      Returns `:ok` on successful removal. Otherwise returns an error.
    """
    @spec remove(Auth.token) :: :ok | { :error, String.t }
    def remove(token), do: GenServer.call(@service, { :remove, { @credential_type }, token })

    @doc """
      Check if an email credential is associated with the identity.

      Returns whether the credential exists or not, if successful. Otherwise returns
      an error.
    """
    @spec exists?(Auth.token) :: { :ok, boolean } | { :error, String.t }
    def exists?(token), do: GenServer.call(@service, { :credential?, { @credential_type }, token })

    @doc """
      Login into an identity using the email credential.

      Returns the session token on successful login. Otherwise returns an error.
    """
    @spec login(String.t, String.t) :: { :ok, Auth.token } | { :error, String.t }
    def login(email, pass), do: GenServer.call(@service, { :login, { @credential_type, { email, pass } } })
end
