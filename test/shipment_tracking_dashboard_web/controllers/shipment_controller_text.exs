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

  describe "POST /api/staff/shipments/:id/events (protected)" do
    test "rejects an unauthenticated request", %{conn: conn} do
      shipment = shipment_fixture()

      conn =
        post(conn, ~p"/api/staff/shipments/#{shipment.id}/events", %{
          "event" => %{
            "occurred_at" => DateTime.utc_now() |> DateTime.truncate(:second),
            "location" => "Bristol Depot",
            "status" => "collected",
            "message" => "Shipment collected"
          }
        })

      assert %{"error" => "unauthenticated"} = json_response(conn, 401)
    end

    test "allows staff to add an event without removing prior ones", %{conn: conn} do
      user = user_fixture()
      shipment = shipment_fixture()
      event_fixture(%{"shipment_id" => shipment.id, "message" => "First event"})

      conn =
        conn
        |> log_in_user(user)
        |> post(~p"/api/staff/shipments/#{shipment.id}/events", %{
          "event" => %{
            "occurred_at" => DateTime.utc_now() |> DateTime.truncate(:second),
            "location" => "Bristol Depot",
            "status" => "out_for_delivery",
            "message" => "Second event"
          }
        })

      assert %{"data" => _} = json_response(conn, 201)

      fetched_conn = get(build_conn(), ~p"/api/shipments/#{shipment.tracking_number}")
      assert %{"data" => %{"events" => events}} = json_response(fetched_conn, 200)

      messages = Enum.map(events, & &1["message"])
      assert "First event" in messages
      assert "Second event" in messages
      assert length(events) == 2
    end
  end
end
