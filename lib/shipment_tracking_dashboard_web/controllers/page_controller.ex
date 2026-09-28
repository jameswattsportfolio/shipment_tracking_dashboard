defmodule ShipmentTrackingDashboardWeb.PageController do
  use ShipmentTrackingDashboardWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/tracking")
  end
end
