defmodule Gobstopper.Service.Auth.Identity.ModelTest do
    use Gobstopper.Service.Case

    alias Gobstopper.Service.Auth.Identity

    test "empty" do
        assert_change(%Identity.Model{})
        |> assert_insert(:ok)
    end

    test "uniqueness" do
        identity = Gobstopper.Service.Repo.insert!(Identity.Model.changeset(%Identity.Model{}))

        assert_change(%Identity.Model{ identity: identity.identity })
        |> assert_insert(:error)
        |> assert_error_value(:identity, { "has already been taken", [] })
    end
end
