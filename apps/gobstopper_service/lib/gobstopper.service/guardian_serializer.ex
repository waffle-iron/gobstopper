defmodule Gobstopper.Service.GuardianSerializer do
    @behaviour Guardian.Serializer

    def for_token(identity = %Gobstopper.Service.Auth.Identity.Model{}), do: { :ok, "Identity:#{identity.id}" }
    def for_token(_), do: { :error, "Unknown resource type" }

    def from_token("Identity:" <> id), do: { :ok, Gobstopper.Service.Repo.get(Gobstopper.Service.Auth.Identity.Model, id) }
    def from_token(_), do: { :error, "Unknown resource type" }
end
