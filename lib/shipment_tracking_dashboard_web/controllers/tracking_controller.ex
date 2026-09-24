defmodule ShipmentTrackingDashboardWeb.TrackingController do
  use ShipmentTrackingDashboardWeb, :controller

  def tracking(conn, _params) do
    IO.inspect("tracking controller")
    render(conn, :tracking)
  end
end
