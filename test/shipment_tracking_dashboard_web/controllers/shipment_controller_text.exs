defmodule ShipmentTrackingDashboardWeb.ShipmentControllerTest do
  use ShipmentTrackingDashboardWeb.ConnCase, async: true

  import ShipmentTrackingDashboard.ShipmentsFixtures
  import ShipmentTrackingDashboard.AccountsFixtures

  describe "GET /api/shipments/:tracking_number (public)" do
    test "returns the shipment for a valid tracking number", %{conn: conn} do
      shipment = shipment_fixture(%{tracking_number: "TRK-DEMO-001"})

      conn = get(conn, ~p"/api/shipments/#{shipment.tracking_number}")

      assert %{"data" => data} = json_response(conn, 200)
      assert data["tracking_number"] == "TRK-DEMO-001"
      assert data["status"] == shipment.status
    end

    test "returns 404 for an unknown tracking number", %{conn: conn} do
      conn = get(conn, ~p"/api/shipments/TRK-DOES-NOT-EXIST")

      assert %{"error" => _} = json_response(conn, 404)
    end

    test "does not leak internal notes in the public response", %{conn: conn} do
      shipment = shipment_fixture(%{internal_notes: "flagged for fraud review"})

      conn = get(conn, ~p"/api/shipments/#{shipment.tracking_number}")

      assert %{"data" => data} = json_response(conn, 200)
      refute Map.has_key?(data, "internal_notes")
    end
  end

  describe "GET /api/staff/shipments (protected)" do
    test "rejects an unauthenticated request", %{conn: conn} do
      conn = get(conn, ~p"/api/staff/shipments")

      assert %{"error" => "unauthenticated"} = json_response(conn, 401)
    end

    test "returns shipments for an authenticated staff user", %{conn: conn} do
      user = user_fixture()
      shipment_fixture(%{tracking_number: "TRK-DEMO-002"})

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/api/staff/shipments")

      assert %{"data" => data} = json_response(conn, 200)
      assert Enum.any?(data, &(&1["tracking_number"] == "TRK-DEMO-002"))
    end
  end
end
