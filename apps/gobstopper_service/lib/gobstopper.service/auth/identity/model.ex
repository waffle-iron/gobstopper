defmodule Gobstopper.Service.Auth.Identity.Model do
    use Ecto.Schema
    import Ecto
    import Ecto.Changeset
    @moduledoc """
      A model representing the different identities.

      ##Fields

      ###:id
      Is the unique reference to the identity entry. Is an `integer`.
    """

    schema "identities" do
        timestamps()
    end

    @doc """
      Builds a changeset for the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [])
    end
end
