defmodule ShipmentTrackingDashboard.Repo do
  use Ecto.Repo,
    otp_app: :shipment_tracking_dashboard,
    adapter: Ecto.Adapters.Postgres
end
