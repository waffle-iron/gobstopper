ExUnit.start()

Gobstopper.Service.Repo.__adapter__.storage_up(Gobstopper.Service.Repo.config)

Gobstopper.Service.start(:normal, [])

migrations = Application.app_dir(:gobstopper_service, "priv/repo/migrations")
Ecto.Migrator.run(Gobstopper.Service.Repo, migrations, :up, all: true)
