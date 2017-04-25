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

      ###:email
      Is the email part of the credential. Is a `string`.

      ###:password
      Is the password part of the credential. Is a `string`.

      ###:password_hash
      Is the hash of the email credential's password. Is a `string`.
    """

    schema "email_credentials" do
        belongs_to :identity, Gobstopper.Service.Auth.Identity.Model
        field :email, :string
        field :password, :string, virtual: true
        field :password_hash, :string
        timestamps()
    end

    @doc """
      Builds a changeset for insertion based on the `struct` and `params`.

      Enforces:
      * `email` field is required
      * `password` field is required
      * `email` field is a valid email
      * `email` field is unique
    """
    def insert_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:identity_id, :email, :password])
        |> validate_required([:identity_id, :email, :password])
        |> validate_email(:email)
        |> format_hash(:password)
        |> unique_constraint(:email)
        |> assoc_constraint(:identity)
        |> unique_constraint(:identity_id)
    end

    @doc """
      Builds a changeset for update based on the `struct` and `params`.

      Enforces:
      * `email` field is not empty
      * `password` field is not empty
      * `email` field is a valid email
      * `email` field is unique
    """
    def update_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:identity_id, :email, :password])
        |> validate_emptiness(:identity_id)
        |> validate_emptiness(:email)
        |> validate_emptiness(:password)
        |> validate_email(:email)
        |> format_hash(:password)
        |> unique_constraint(:email)
        |> assoc_constraint(:identity)
        |> unique_constraint(:identity_id)
    end
end
