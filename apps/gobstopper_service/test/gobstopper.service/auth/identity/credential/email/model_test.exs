defmodule Gobstopper.Service.Auth.Identity.Credential.Email.ModelTest do
    use Gobstopper.Service.Case

    alias Gobstopper.Service.Auth.Identity.Credential.Email

    @valid_model %Email.Model{
        identity_id: 1,
        password: "test",
        password_hash: "test"
    }

    test "empty" do
        refute_change(%Email.Model{}, %{}, :insert_changeset)
    end

    test "only identity" do
        refute_change(%Email.Model{}, %{ identity_id: @valid_model.identity_id }, :insert_changeset)

        assert_change(@valid_model, %{ identity_id: 0 }, :update_changeset)
    end

    test "only password" do
        refute_change(%Email.Model{}, %{ password: @valid_model.password }, :insert_changeset)

        assert_change(@valid_model, %{ password: "new" }, :update_changeset)
    end

    test "without identity" do
        refute_change(@valid_model, %{ identity_id: nil }, :insert_changeset)
    end

    test "without password" do
        refute_change(@valid_model, %{ password: nil }, :insert_changeset)
    end

    test "valid model" do
        assert_change(@valid_model, %{}, :insert_changeset)

        assert_change(@valid_model, %{}, :update_changeset)
    end

    test "password hashing" do
        assert_change(@valid_model, %{}, :insert_changeset)
        |> refute_change_field(:password_hash)

        assert_change(@valid_model, %{ password: "pass" }, :insert_changeset)
        |> assert_change_field(:password_hash)

        assert_change(@valid_model, %{}, :update_changeset)
        |> refute_change_field(:password_hash)

        assert_change(@valid_model, %{ password: "pass" }, :update_changeset)
        |> assert_change_field(:password_hash)
    end

    test "uniqueness" do
        identity = Gobstopper.Service.Repo.insert!(Gobstopper.Service.Auth.Identity.Model.changeset(%Gobstopper.Service.Auth.Identity.Model{}))
        identity2 = Gobstopper.Service.Repo.insert!(Gobstopper.Service.Auth.Identity.Model.changeset(%Gobstopper.Service.Auth.Identity.Model{}))
        credential = Gobstopper.Service.Repo.insert!(Email.Model.insert_changeset(@valid_model, %{ identity_id: identity.id }))

        assert_change(@valid_model, %{ identity_id: identity.id }, :insert_changeset)
        |> assert_insert(:error)
        |> assert_error_value(:identity_id, { "has already been taken", [] })

        assert_change(@valid_model, %{ identity_id: 0 }, :insert_changeset)
        |> assert_insert(:error)
        |> assert_error_value(:identity, { "does not exist", [] })

        assert_change(@valid_model, %{ identity_id: identity2.id }, :insert_changeset)
        |> assert_insert(:ok)
    end

    test "update" do
        identity = Gobstopper.Service.Repo.insert!(Gobstopper.Service.Auth.Identity.Model.changeset(%Gobstopper.Service.Auth.Identity.Model{}))
        credential_foo = Gobstopper.Service.Repo.insert!(Email.Model.insert_changeset(%Email.Model{}, %{ identity_id: identity.id,  password: "test" }))

        assert { :ok, credential } = Gobstopper.Service.Repo.update(Email.Model.update_changeset(credential_foo, %{ password: "new" }))
        assert credential.password_hash != credential_foo.password_hash
    end
end
