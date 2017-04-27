defmodule Gobstopper.Service.Auth.Identity.ModelTest do
    use Gobstopper.Service.Case

    alias Gobstopper.Service.Auth.Identity

    @valid_model %Identity.Model{}

    test "empty" do
        assert_change(%Identity.Model{})
        |> assert_insert(:ok)
    end
end
