defmodule ShipmentTrackingDashboardWeb.PageControllerTest do
  use ShipmentTrackingDashboardWeb.ConnCase

  test "GET / redirects to the tracking page", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/tracking"
  end
end
