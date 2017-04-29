defmodule Gobstopper.API.Auth.EmailTest do
    use Gobstopper.Service.Case

    alias Gobstopper.API.Auth

    setup do
        cred = %{ email: "test@test", pass: "test" }
        { :ok, _ } = Auth.Email.register(cred.email, cred.pass)
        { :ok, cred }
    end

    describe "registration/2" do
        test "invalid registration" do
            assert { :error, "Failed to create credential" } == Auth.Email.register("foo", "secret")
        end

        test "valid registration" do
            assert { :ok, token } = Auth.Email.register("foo@bar", "secret")
            assert nil != Auth.verify(token)
        end

        test "conflicting registration", %{ email: email, pass: pass } do
            assert { :error, "Failed to create credential" } == Auth.Email.register(email, pass)
        end
    end

    describe "login/2" do
        test "invalid login", %{ email: email, pass: pass } do
            assert { :error, "Invalid credentials" } == Auth.Email.login(email, pass <> "_")
        end

        test "valid login", %{ email: email, pass: pass } do
            assert { :ok, token } = Auth.Email.login(email, pass)
            assert nil != Auth.verify(token)
        end
    end

    describe "get/1" do
        test "invalid get" do
            assert { :error, "Invalid token" } == Auth.Email.get(nil)
        end

        test "valid get", %{ email: email, pass: pass } do
            { :ok, token } = Auth.Email.login(email, pass)
            assert { :ok, { :unverified, email } } == Auth.Email.get(token)
        end
    end

    describe "set/3" do
        test "invalid set", %{ email: email } do
            assert { :error, "Invalid token" } == Auth.Email.set(nil, "foo@bar", "secret")

            { :ok, token } = Auth.Email.register("foo@bar", "secret")
            assert { :error, "Failed to create credential" } == Auth.Email.set(token, email, "secret`")
        end

        test "valid set" do
            { :ok, token } = Auth.Email.register("foo@bar", "secret")
            assert :ok == Auth.Email.set(token, "foo@foo", "secret")
            assert { :ok, { :unverified, "foo@foo" } } == Auth.Email.get(token)
            assert { :error, "Invalid credentials" } == Auth.Email.login("foo@bar", "secret")
            assert { :ok, _ } = Auth.Email.login("foo@foo", "secret")
        end
    end

    describe "remove/1" do
        test "invalid remove" do
            assert { :error, "Invalid token" } == Auth.Email.remove(nil)

            { :ok, token } = Auth.Email.register("foo@bar", "secret")
            :ok = Auth.Email.remove(token)
            assert { :error, "No email credential exists" } == Auth.Email.remove(token)
        end

        test "valid remove" do
            { :ok, token } = Auth.Email.register("foo@bar", "secret")
            assert :ok == Auth.Email.remove(token)
            assert { :ok, { :none, nil } } == Auth.Email.get(token)
            assert { :error, "Invalid credentials" } == Auth.Email.login("foo@bar", "secret")
            assert :ok = Auth.Email.set(token, "foo@bar", "secret")
            assert { :ok, { :unverified, "foo@bar" } } == Auth.Email.get(token)
            assert { :ok, _ } = Auth.Email.login("foo@bar", "secret")
        end
    end

    describe "exists?" do
        test "invalid exists?" do
            assert { :error, "Invalid token" } == Auth.Email.exists?(nil)
        end

        test "valid exists?" do
            { :ok, token } = Auth.Email.register("foo@bar", "secret")
            assert { :ok, true } == Auth.Email.exists?(token)
            :ok = Auth.Email.remove(token)
            assert { :ok, false } == Auth.Email.exists?(token)
        end
    end
end
