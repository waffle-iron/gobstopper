defmodule Gobstopper.Service.Auth.Identity do
    @moduledoc """
      Provides interfaces to identities.

      Requires operations that have restricted access, meet those requirements.
    """

    require Logger
    alias Gobstopper.Service.Auth.Identity

    @spec create(atom, term) :: { :ok, String.t } | { :error, String.t }
    def create(type, credential) do
        with { :identity, { :ok, identity } } <- { :identity, Gobstopper.Service.Repo.insert(Identity.Model.changeset(%Identity.Model{})) },
             { :create_credential, :ok } <- { :create_credential, Identity.Credential.create(type, identity.id, credential) },
             { :jwt, { :ok, jwt, _ } } <- { :jwt, Guardian.encode_and_sign(identity) } do
                { :ok, jwt }
        else
            { :identity, { :error, changeset } } ->
                Logger.debug("create identity: #{inspect(changeset.errors)}")
                { :error, "Failed to create credential" }
            { :create_credential, { :error, reason } } -> { :error, reason }
            { :jwt, { :error, _ } } -> { :error, "Could not create JWT" }
        end
    end

    @spec create(atom, term, String.t) :: :ok | { :error, String.t }
    def create(type, credential, token) do
        with { :identity, identity } when is_integer(identity) <- { :identity, verify(token) },
             { :create_credential, :ok } <- { :create_credential, Identity.Credential.create(type, identity, credential) } do
                :ok
        else
            { :identity, nil } -> { :error, "Invalid token" }
            { :create_credential, { :error, reason } } -> { :error, reason }
        end
    end

    @spec update(atom, term, String.t) :: :ok | { :error, String.t }
    def update(type, credential, token) do
        case verify(token) do
            nil -> { :error, "Invalid token" }
            identity -> Identity.Credential.change(type, identity, credential)
        end
    end

    @spec remove(atom, String.t) :: :ok | { :error, String.t }
    def remove(type, token) do
        case verify(token) do
            nil -> { :error, "Invalid token" }
            identity -> Identity.Credential.revoke(type, identity)
        end
    end

    @spec login(atom, term) :: { :ok, String.t } | { :error, String.t }
    def login(type, credential) do
        with { :id, { :ok, id } } <- { :id, Identity.Credential.authenticate(type, credential) },
             { :identity, identity = %Identity.Model{} } <- { :identity, Gobstopper.Service.Repo.get(Identity.Model, id) },
             { :jwt, { :ok, jwt, _ } } <- { :jwt, Guardian.encode_and_sign(identity) } do
                { :ok, jwt }
        else
            { :id, { :error, reason } } -> { :error, reason }
            { :identity, nil } ->
                Logger.debug("get identity: #{inspect(Identity.Credential.authenticate(type, credential))}")
                { :error, "Invalid credentials" }
            { :jwt, { :error, _ } } -> { :error, "Could not create JWT" }
        end
    end

    @spec logout(String.t) :: :ok | { :error, String.t }
    def logout(token) do
        case Guardian.revoke!(token) do
            :ok -> :ok
            _ -> { :error, "Could not logout of session" }
        end
    end

    @spec verify(String.t) :: integer | nil
    def verify(token) do
        with { :ok, %{ "sub" => sub } } <- Guardian.decode_and_verify(token),
             { :ok, identity } <- Guardian.serializer.from_token(sub) do
                identity.id
        else
            _ -> nil
        end
    end

    @spec credential?(atom, String.t) :: { :ok, boolean } | { :error, String.t }
    def credential?(type, token) do
        case verify(token) do
            nil -> { :error, "Invalid token" }
            identity -> { :ok, Identity.Credential.credential?(type, identity) }
        end
    end

    @credential_types Enum.filter(for type <- Path.wildcard(Path.join(__DIR__, "identity/credential/*.ex")) do
        name = Path.basename(type)
        size = byte_size(name) - 3
        case name do
            <<credential :: size(size)-binary, ".ex">> -> String.to_atom(String.downcase(credential))
            _ -> nil
        end
    end, &(&1 != nil))

    @spec all_credentials(String.t) :: { :ok, [{ atom, { :unverified | :verified, String.t } | { :none, nil } }] } | { :error, String.t }
    def all_credentials(token) do
        case verify(token) do
            nil -> { :error, "Invalid token" }
            identity -> { :ok, (for type <- @credential_types, do: { type, Identity.Credential.info(type, identity) }) }
        end
    end
end
