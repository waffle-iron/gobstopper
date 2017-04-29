defmodule Gobstopper.Service.Auth.Identity.Model do
    use Ecto.Schema
    import Ecto
    import Ecto.Changeset
    @moduledoc """
      A model representing the different identities.

      ##Fields

      ###:id
      Is the unique reference to the identity entry. Is an `integer`.

      ###:identity
      Is the unique ID to externally reference the identity entry. Is an `uuid`.
    """

    schema "identities" do
        field :identity, Ecto.UUID, read_after_writes: true
        timestamps()
    end

    @doc """
      Builds a changeset for the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [])
        |> unique_constraint(:identity)
    end
end
