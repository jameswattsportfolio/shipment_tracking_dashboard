defmodule ShipmentTrackingDashboardWeb.Api.TrackingController do
  use ShipmentTrackingDashboardWeb, :controller

  def tracking(conn, _params) do
    render(conn, :tracking)
  end
end
