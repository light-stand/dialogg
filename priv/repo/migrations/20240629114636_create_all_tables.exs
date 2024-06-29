defmodule Dialogg.Repo.Migrations.CreateAllTables do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :string, primary_key: true, size: 500
      add :created_at, :naive_datetime, default: fragment("CURRENT_TIMESTAMP")
    end

    create table(:rooms, primary_key: false) do
      add :id, :string, primary_key: true, size: 500
      add :created_at, :naive_datetime, default: fragment("CURRENT_TIMESTAMP")
    end

    create table(:user_rooms, primary_key: false) do
      add :user_id, references(:users, type: :string, on_delete: :delete_all), primary_key: true
      add :room_id, references(:rooms, type: :string, on_delete: :delete_all), primary_key: true
      add :joined_at, :naive_datetime, default: fragment("CURRENT_TIMESTAMP")
    end

    create index(:user_rooms, [:user_id])
    create index(:user_rooms, [:room_id])

    create table(:messages, primary_key: false) do
      add :id, :string, primary_key: true, size: 500
      add :user_id, references(:users, type: :string, on_delete: :delete_all), null: false
      add :room_id, references(:rooms, type: :string, on_delete: :delete_all), null: false
      add :message_text, :text, null: false
      add :sent_at, :naive_datetime, default: fragment("CURRENT_TIMESTAMP")
    end

    create index(:messages, [:user_id])
    create index(:messages, [:room_id])
  end
end
