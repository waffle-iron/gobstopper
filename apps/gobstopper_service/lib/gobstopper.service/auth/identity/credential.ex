defmodule Gobstopper.Service.Auth.Identity.Credential do
    @moduledoc """
      Manages the interactions with credentials.

      Credential implementations will implement the given callbacks to handle the
      specific credential type.

      ##Implementing a credential

      Credentials should be implemented in a module conforming to
      `#{String.slice(to_string(__MODULE__), 7..-1)}.type`. Where type is the capitalized
      credential type.

      e.g. For a credential that should be identified using the :email atom, then the
      implementation for that credential should fall under `#{String.slice(to_string(__MODULE__), 7..-1)}.Email`.
    """

    @doc """
      Implement the behaviour for creating a new credential and associating it with
      the given identity.

      An identity should only have one credential of type. If the identity is attempting
      to create a new credential for the same type, an error should be returned.

      If the operation was successful return `:ok`.
    """
    @callback create(identity :: integer, credential :: term) :: :ok | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for changing a credential that is associated with the
      given identity.

      If the operation was successful return `:ok`. Otherwise return the error.
    """
    @callback change(identity :: integer, credential :: term) :: :ok | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for revoking the credential associated with the given
      identity.

      If the identity has no credential, then it should return an error.

      If the operation was successful return `:ok`.
    """
    @callback revoke(identity :: integer) :: :ok | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for identifying if a credential exists for the given
      identity.

      If one exists return true, otherwise return false.
    """
    @callback credential?(identity :: integer) :: boolean

    @doc """
      Implement the behaviour for retrieving the presentable information for the
      credential of a given identity.

      If one exists return the state of the credential (`:unverified` or `:verified`)
      and the presentable string. Otherwise return `{ :none, nil }`.

      Verification state is used to infer whether the given credential is guaranteed
      to be owned by the identity owner.
    """
    @callback info(identity :: integer) :: { state :: :unverified | :verified, presentable :: String.t } | { :none, nil }

    @doc """
      Implement the behaviour for authenticating an identity using the given credential.

      If the operation was successful return `{ :ok, identity }`, where `identity` is
      the identity of the authenticated credential. Otherwise return an error.
    """
    @callback authenticate(credential :: term) :: { :ok, identity :: integer } | { :error, reason :: String.t }

    @doc """
      Create the credential type for the given identity.

      If the credential is valid, and the identity doesn't already have a credential
      of that type associated with it, then it will succeed. Otherwise returns the
      reason of failure.
    """
    @spec create(atom, integer, term) :: :ok | { :error, String.t }
    def create(type, identity, credential) do
        atom_to_module(type).create(identity, credential)
    end

    @doc """
      Change the credential of type belonging to the identity.

      Returns `:ok` if the operation was successful, otherwise returns an error.
    """
    @spec change(atom, integer, term) :: :ok | { :error, String.t }
    def change(type, identity, credential) do
        atom_to_module(type).change(identity, credential)
    end

    @doc """
      Revoke the credential of type belonging to the identity.

      Returns `:ok` if the operation was successful, otherwise returns an error if
      there was no such credential or the operation could not be completed.
    """
    @spec revoke(atom, integer) :: :ok | { :error, String.t }
    def revoke(type, identity) do
        atom_to_module(type).revoke(identity)
    end

    @doc """
      Check if a credential of type exists for the given identity.

      Returns true if one exists, otherwise false.
    """
    @spec credential?(atom, integer) :: boolean
    def credential?(type, identity) do
        atom_to_module(type).credential?(identity)
    end

    @doc """
      Retrieve the info for the type of credential of an identity.

      If a credential exists the return value will consist of the state of the
      credential (`:unverified` or `:verified`) and the presentable string. Otherwise
      it will return `{ :none, nil }`.
    """
    @spec info(atom, integer) :: { :unverified | :verified, String.t } | { :none, nil }
    def info(type, identity) do
        atom_to_module(type).info(identity)
    end

    @doc """
      Authenticate the type of credential.

      If credential can be successfully authenticated, then it returns the identity.
      Otherwise returns the reason of failure.
    """
    @spec authenticate(atom, term) :: { :ok, integer } | { :error, String.t }
    def authenticate(type, credential) do
        atom_to_module(type).authenticate(credential)
    end

    @spec atom_to_module(atom) :: atom
    defp atom_to_module(name) do
        String.to_atom(to_string(__MODULE__) <> "." <> format_as_module(to_string(name)))
    end

    @spec format_as_module(String.t) :: String.t
    defp format_as_module(name) do
        name
        |> String.split(".")
        |> Enum.map(fn module ->
            String.split(module, "_") |> Enum.map(&String.capitalize(&1)) |> Enum.join
        end)
        |> Enum.join(".")
    end
end
