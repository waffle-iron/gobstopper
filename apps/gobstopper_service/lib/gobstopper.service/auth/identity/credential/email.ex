defmodule Gobstopper.Service.Auth.Identity.Credential.Email do
    @moduledoc """
      Support email/password based credentials.
    """

    @behaviour Gobstopper.Service.Auth.Identity.Credential

    alias Gobstopper.Service.Auth.Identity
    alias Gobstopper.Service.Auth.Identity.Credential
    alias Sherbet.API.Contact
    require Logger

    #todo: should error reasons expose changeset.errors?

    @type uuid :: String.t

    def create(identity, { email, pass }) do
        with { :credential, { :ok, _ } } <- { :credential, Gobstopper.Service.Repo.insert(Credential.Email.Model.insert_changeset(%Credential.Email.Model{}, %{ password: pass, identity_id: identity.id })) },
             { :email, { :ok, _ } } <- { :email, new_email(identity.identity, email) } do
                :ok
        else
            { :credential, { :error, changeset } } ->
                Logger.debug("create: #{inspect(changeset.errors)}")
                { :error, "Failed to create credential" }
            { :email, { { :error, _ }, _ } } ->
                revoke(identity)
                { :error, "Failed to create credential" }
        end
    end

    def change(identity, { email, pass }) do
        with { :credential, credential = %Credential.Email.Model{} } <- { :credential, Gobstopper.Service.Repo.get_by(Credential.Email.Model, identity_id: identity.id) },
             { :email, { { :ok, prev_email }, { :ok, source } } } <- { :email, set_email(identity.identity, email) } do
                case Gobstopper.Service.Repo.update(Credential.Email.Model.insert_changeset(credential, %{ password: pass, identity_id: identity.id })) do
                    { :ok, _ } -> :ok
                    { :error, changeset } ->
                        :ok = case source do
                            :new ->
                                :ok = Contact.Email.remove(identity.identity, email)

                                case prev_email do
                                    :same -> :error
                                    nil -> :ok
                                    email -> Contact.Email.set_priority(identity.identity, email, :primary)
                                end

                            :existing ->
                                case prev_email do
                                    :same -> :ok
                                    nil -> Contact.Email.set_priority(identity.identity, email, :secondary)
                                    email -> Contact.Email.set_priority(identity.identity, email, :primary)
                                end
                        end

                        Logger.debug("change: #{inspect(changeset.errors)}")
                        { :error, "Failed to change credential" }
                end
        else
            { :credential, nil } -> { :error, "No email credential exists" }
            { :email, { _, { { :error, _ }, _ } } } -> { :error, "Failed to change credential" }
        end
    end

    def revoke(identity) do
        with { :credential, credential = %Credential.Email.Model{} } <- { :credential, Gobstopper.Service.Repo.get_by(Credential.Email.Model, identity_id: identity.id) },
             { :delete, { :ok, _ } } <- { :delete, Gobstopper.Service.Repo.delete(credential) } do
                :ok
        else
            { :credential, nil } -> { :error, "No email credential exists" }
            { :delete, { :error, changeset } } ->
                Logger.debug("change: #{inspect(changeset.errors)}")
                { :error, "Failed to revoke credential" }
        end
    end

    def credential?(identity) do
        nil != Gobstopper.Service.Repo.get_by(Credential.Email.Model, identity_id: identity.id)
    end

    def info(identity) do
        case credential?(identity) do
            false -> { :none, nil }
            true ->
                case Contact.Email.primary_contact(identity.identity) do
                    { :ok, info } -> info
                    { :error, _ } -> { :none, nil }
                end
        end
    end

    def authenticate({ email, pass }) do
        with { :owner, { :ok, id } } <- { :owner, Contact.Email.owner(email) },
             { :primary, { :ok, { _, ^email } } } <- { :primary, Contact.Email.primary_contact(id) },
             { :identity, identity = %Identity.Model{} } <- { :identity, Gobstopper.Service.Repo.get_by(Identity.Model, identity: id) },
             { :credential, credential = %Credential.Email.Model{} } <- { :credential, Gobstopper.Service.Repo.get_by(Credential.Email.Model, identity_id: identity.id) },
             { :match, true } <- { :match, match(credential, pass) } do
                { :ok, identity }
        else
            { :owner, { :error, _ } } -> { :error, "Invalid credentials" }
            { :primary, _ } -> { :error, "Invalid credentials" }
            { :identity, nil } -> { :error, "Invalid credentials" }
            { :credential, nil } -> { :error, "Invalid credentials" }
            { :match, false } -> { :error, "Invalid credentials" }
        end
    end

    @spec match(Ecto.Schema.t | nil, String.t) :: boolean()
    defp match(nil, _), do: false
    defp match(credential, pass), do: Comeonin.Bcrypt.checkpw(pass, credential.password_hash)

    @spec new_email(uuid, String.t) :: { :ok | { :error, String.t }, :exising | :new }
    defp new_email(identity, email) do
        case Contact.Email.set_priority(identity, email, :primary) do
            :ok -> { :ok, :existing }
            _ -> { Contact.Email.add(identity, email, :primary), :new }
        end
    end

    @spec set_email(uuid, String.t) :: { { :ok, prev_email :: String.t | :same | nil }, { :ok | { :error, String.t }, :exising | :new } }
    defp set_email(identity, email) do
        case Contact.Email.primary_contact(identity) do
            { :ok, { _, ^email } } -> { { :ok, :same }, { :ok, :existing } }
            { :ok, { _, prev_email } } -> { { :ok, prev_email }, new_email(identity, email) }
            _ -> { { :ok, nil }, new_email(identity, email) }
        end
    end
end
