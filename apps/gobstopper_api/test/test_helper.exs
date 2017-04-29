#For now run test from the umbrella project root
# Gobstopper.Service.Repo.__adapter__.storage_up(Gobstopper.Service.Repo.config)

Application.ensure_all_started(:gobstopper_service)
Application.ensure_all_started(:ecto)

# migrations = Application.app_dir(:gobstopper_service, "priv/repo/migrations")
# Ecto.Migrator.run(Gobstopper.Service.Repo, migrations, :up, all: true)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Gobstopper.Service.Repo, :manual)
