defmodule ShipmentTrackingDashboardWeb.TrackingController do
  use ShipmentTrackingDashboardWeb, :controller

  def tracking(conn, _params) do
    IO.puts("tracking controller")
    render(conn, :tracking)
  end
end
