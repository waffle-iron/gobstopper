defmodule Gobstopper.Service.Repo.Migrations.CreateEmailCredential do
    use Ecto.Migration

    def change do
        create table(:email_credentials) do
            add :identity_id, references(:identities),
                null: false

            # add :email, :string,
            #     null: false

            add :password_hash, :string,
                null: false

            timestamps()
        end

        create index(:email_credentials, [:identity_id], unique: true)
        # create index(:email_credentials, [:email], unique: true)
    end
end
