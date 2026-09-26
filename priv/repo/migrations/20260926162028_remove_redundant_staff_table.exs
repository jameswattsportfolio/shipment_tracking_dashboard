defmodule ShipmentTrackingDashboard.Repo.Migrations.RemoveRedundantStaffTable do
  use Ecto.Migration

  def up do
    drop_if_exists table(:staff)
  end

  # No meaningful down() required
  def down do
  end
end
