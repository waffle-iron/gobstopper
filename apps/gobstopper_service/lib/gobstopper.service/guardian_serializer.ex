defmodule Gobstopper.Service.GuardianSerializer do
    @behaviour Guardian.Serializer

    def for_token(_), do: { :error, "Unknown resource type" }

    def from_token(_), do: { :error, "Unknown resource type" }
end
