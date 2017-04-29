defmodule Gobstopper.Service.Repo.Migrations.CreateIdentity do
    use Ecto.Migration

    def change do
        create table(:identities) do
            add :identity, :uuid,
                default: fragment("uuid_generate_v4()"),
                null: false

            timestamps()
        end

        create index(:identities, [:identity], unique: true)
    end
end
