defmodule ShipmentTrackingDashboardWeb.PageControllerTest do
  use ShipmentTrackingDashboardWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/staff/dashboard")
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end
end
