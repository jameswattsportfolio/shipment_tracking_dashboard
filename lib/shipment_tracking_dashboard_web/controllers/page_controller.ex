defmodule ShipmentTrackingDashboardWeb.Api.PageController do
  use ShipmentTrackingDashboardWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
