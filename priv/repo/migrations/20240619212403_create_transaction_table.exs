defmodule Rate.Repo.Migrations.CreateTransactionTable do
  use Ecto.Migration

  def change do
    create table(:transaction) do
      add :from_amount, :integer, null: false
      add :from_currency, :string, null: false
      add :to_currency, :string, null: false
      add :conversion_rate, :float, null: false
      add :external_id, :string, unique: true, null: false
      add :user_id, references(:user), null: true

      timestamps()
    end
  end
end
