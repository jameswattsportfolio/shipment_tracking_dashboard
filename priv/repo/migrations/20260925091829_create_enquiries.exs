defmodule ShipmentTrackingDashboard.Repo.Migrations.CreateEnquiries do
  use Ecto.Migration

  def change do
    create table(:enquiries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tracking_number, :string, null: false
      add :category, :string, null: false
      add :message, :text, null: false
      add :status, :string, null: false, default: "open"

      timestamps(type: :utc_datetime)
    end

    create index(:enquiries, [:tracking_number])
    create index(:enquiries, [:status])
  end
end
