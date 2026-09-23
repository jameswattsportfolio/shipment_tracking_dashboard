defmodule ShipmentTrackingDashboard.Repo.Migrations.CreateStaffAndShipmentTables do
  use Ecto.Migration

  def change do
    # primary_key: false to disable auto generation of a primary key
    create table(:staff, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :role, :string, null: false
      add :password_hash, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:staff, [:email])

    create table(:shipments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tracking_number, :string, null: false
      add :status, :string, default: :created, null: false
      add :current_location, :string, null: false
      add :origin, :string, null: false
      add :destination, :string, null: false
      add :service_level, :string
      add :total_weight, :decimal
      add :package_count, :integer
      add :expected_delivery_date, :date
      add :actual_delivery_date, :date
      add :shipment_notes, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:shipments, [:tracking_number])
  end
end
