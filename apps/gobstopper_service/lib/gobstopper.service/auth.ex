defmodule Gobstopper.Service.Auth do
    use GenServer

    alias Gobstopper.Service.Auth.Identity

    def start_link() do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def handle_call({ :create, { type, credential } }, _from, state), do: { :reply, Identity.create(type, credential), state }
    def handle_call({ :create, { type, credential }, token }, _from, state), do: { :reply, Identity.create(type, credential, token), state }
    def handle_call({ :update, { type, credential }, token }, _from, state), do: { :reply, Identity.update(type, credential, token), state }
    def handle_call({ :remove, { type }, token }, _from, state), do: { :reply, Identity.remove(type, token), state }
    def handle_call({ :login, { type, credential } }, _from, state), do: { :reply, Identity.login(type, credential), state }
    def handle_call({ :verify, token }, _from, state), do: { :reply, Identity.verify(token), state }
    def handle_call({ :credential?, { type }, token }, _from, state), do: { :reply, Identity.credential?(type, token), state }
    def handle_call({ :all_credentials, token }, _from, state), do: { :reply, Identity.all_credentials(token), state }

    def handle_cast({ :logout, token }, state) do
        Identity.logout(token)
        { :noreply, state }
    end
end
