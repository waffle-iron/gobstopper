defmodule Gobstopper.Service do
    @moduledoc false

    use Application

    def start(_type, _args) do
        import Supervisor.Spec, warn: false

        children = [
            supervisor(Gobstopper.Service.Repo, []),
            worker(GuardianDb.ExpiredSweeper, [])
        ]

        opts = [strategy: :one_for_one, name: Gobstopper.Service.Supervisor]
        Supervisor.start_link(children, opts)
    end
end
