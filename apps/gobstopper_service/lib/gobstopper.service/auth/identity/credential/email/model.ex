defmodule Gobstopper.Service.Auth.Identity.Credential.Email.Model do
    use Ecto.Schema
    import Ecto
    import Ecto.Changeset
    import Protecto
    @moduledoc """
      A model representing the different email credentials.

      ##Fields

      ###:id
      Is the unique reference to the email credential entry. Is an `integer`.

      ###:identity_id
      Is the identity the email credential belongs to. Is an `integer`.

      ###:password
      Is the password part of the credential. Is a `string`.

      ###:password_hash
      Is the hash of the email credential's password. Is a `string`.
    """

    schema "email_credentials" do
        belongs_to :identity, Gobstopper.Service.Auth.Identity.Model
        field :password, :string, virtual: true
        field :password_hash, :string
        timestamps()
    end

    @doc """
      Builds a changeset for insertion based on the `struct` and `params`.

      Enforces:
      * `identity_id` field is required
      * `password` field is required
      * `identity_id` field is unique
      * `identity_id` field is associated with an entry in `Gobstopper.Service.Auth.Identity.Model`
    """
    def insert_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:identity_id, :password])
        |> validate_required([:identity_id, :password])
        |> format_hash(:password)
        |> assoc_constraint(:identity)
        |> unique_constraint(:identity_id)
    end

    @doc """
      Builds a changeset for update based on the `struct` and `params`.

      Enforces:
      * `identity_id` field is not empty
      * `password` field is not empty
      * `identity_id` field is unique
      * `identity_id` field is associated with an entry in `Gobstopper.Service.Auth.Identity.Model`
    """
    def update_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:identity_id, :password])
        |> validate_emptiness(:identity_id)
        |> validate_emptiness(:password)
        |> format_hash(:password)
        |> assoc_constraint(:identity)
        |> unique_constraint(:identity_id)
    end
end
