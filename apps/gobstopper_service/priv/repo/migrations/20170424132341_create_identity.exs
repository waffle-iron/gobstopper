defmodule Gobstopper.Service.Repo.Migrations.CreateIdentity do
    use Ecto.Migration

    def change do
        create table(:identities) do
            timestamps()
        end
    end
end
