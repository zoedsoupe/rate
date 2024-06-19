defmodule Rate.Repo.Migrations.CreateUserTable do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :email, :string, null: false, unique: true
      add :external_id, :string, null: false, unique: true

      timestamps()
    end
  end
end
