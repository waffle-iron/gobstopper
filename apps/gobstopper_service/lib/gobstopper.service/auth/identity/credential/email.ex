defmodule Gobstopper.Service.Auth.Identity.Credential.Email do
    @moduledoc """
      Support email/password based credentials.
    """

    @behaviour Gobstopper.Service.Auth.Identity.Credential

    alias Gobstopper.Service.Auth.Identity.Credential
    require Logger

    #todo: should error reasons expose changeset.errors?

    def create(identity, { email, pass }) do
        credential =
            %Credential.Email.Model{}
            |> Credential.Email.Model.insert_changeset(%{ email: email, password: pass, identity_id: identity })
            |> Gobstopper.Service.Repo.insert

        case credential do
            { :ok, _ } -> :ok
            { :error, changeset } ->
                Logger.debug("create: #{inspect(changeset.errors)}")
                { :error, "Failed to create credential" }
        end
    end

    def change(identity, { email, pass }) do
        with { :credential, credential = %Credential.Email.Model{} } <- { :credential, Gobstopper.Service.Repo.get_by(Credential.Email.Model, identity_id: identity) },
             { :update, { :ok, _ } } <- { :update, Gobstopper.Service.Repo.update(Credential.Email.Model.insert_changeset(credential, %{ email: email, password: pass, identity_id: identity })) } do
                :ok
        else
            { :credential, nil } -> { :error, "No email credential exists" }
            { :update, { :error, changeset }} ->
                Logger.debug("change: #{inspect(changeset.errors)}")
                { :error, "Failed to change credential" }
        end
    end

    def revoke(identity) do
        with { :credential, credential = %Credential.Email.Model{} } <- { :credential, Gobstopper.Service.Repo.get_by(Credential.Email.Model, identity_id: identity) },
             { :delete, { :ok, _ } } <- { :delete, Gobstopper.Service.Repo.delete(credential) } do
                :ok
        else
            { :credential, nil } -> { :error, "No email credential exists" }
            { :delete, { :error, changeset }} ->
                Logger.debug("change: #{inspect(changeset.errors)}")
                { :error, "Failed to revoke credential" }
        end
    end

    def credential?(identity) do
        nil != Gobstopper.Service.Repo.get_by(Credential.Email.Model, identity_id: identity)
    end

    def info(identity) do
        case Gobstopper.Service.Repo.get_by(Credential.Email.Model, identity_id: identity) do
            nil -> { :none, nil }
            credential -> { :unverified, credential.email } #todo: call email service to check if it has been verified
        end
    end

    def authenticate({ email, pass }) do
        credential = Gobstopper.Service.Repo.get_by(Credential.Email.Model, email: email)
        case match(credential, pass) do
            true -> { :ok, credential.identity_id }
            false -> { :error, "Invalid credentials" }
        end
    end

    @spec match(Ecto.Schema.t, String.t) :: boolean()
    defp match(nil, _), do: false
    defp match(credential, pass), do: Comeonin.Bcrypt.checkpw(pass, credential.password_hash)
end
