defmodule ShipmentTrackingDashboard.Repo.Migrations.CreateShipmentEvents do
  use Ecto.Migration

  def change do
    create table(:shipment_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :occurred_at, :utc_datetime, null: false
      add :location, :string, null: false
      add :status, :string, null: false
      add :message, :string, null: false

      add :shipment_id, references(:shipments, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:shipment_events, [:shipment_id])
  end
end
