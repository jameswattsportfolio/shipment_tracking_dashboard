defmodule ShipmentTrackingDashboardWeb.TrackingLiveTest do
  use ShipmentTrackingDashboardWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import ShipmentTrackingDashboard.ShipmentsFixtures

  describe "GET /tracking" do
    test "renders the search form with no shipment loaded", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/tracking")

      assert html =~ "Track Your Shipment"
      refute html =~ "Tracking Timeline"
    end

    test "searching a valid tracking number shows shipment details and timeline", %{conn: conn} do
      shipment = shipment_fixture(%{"tracking_number" => "TRK-DEMO-001", "status" => "collected"})
      event_fixture(%{"shipment_id" => shipment.id, "message" => "Collected from sender"})

      {:ok, view, _html} = live(conn, ~p"/tracking")

      html =
        view
        |> element("form[phx-submit='search']")
        |> render_submit(%{"tracking" => %{"tracking_number" => "TRK-DEMO-001"}})

      assert html =~ "TRK-DEMO-001"
      assert html =~ "Collected from sender"
      assert html =~ "Tracking Timeline"
    end

    test "searching an unknown tracking number shows a not-found message, not a crash", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/tracking")

      html =
        view
        |> element("form[phx-submit='search']")
        |> render_submit(%{"tracking" => %{"tracking_number" => "TRK-DOES-NOT-EXIST"}})

      assert html =~ "couldn&#39;t find a shipment"
      refute html =~ "Tracking Timeline"
    end

    test "a shipment with no events yet shows the empty-state message, not a blank section", %{
      conn: conn
    } do
      shipment_fixture(%{"tracking_number" => "TRK-DEMO-005"})

      {:ok, view, _html} = live(conn, ~p"/tracking")

      html =
        view
        |> element("form[phx-submit='search']")
        |> render_submit(%{"tracking" => %{"tracking_number" => "TRK-DEMO-005"}})

      assert html =~ "No tracking events yet"
    end

    test "search results are reflected in the URL for bookmarking", %{conn: conn} do
      shipment_fixture(%{"tracking_number" => "TRK-DEMO-002"})

      {:ok, view, _html} = live(conn, ~p"/tracking")

      {:ok, _view, _html} =
        view
        |> element("form[phx-submit='search']")
        |> render_submit(%{"tracking" => %{"tracking_number" => "TRK-DEMO-002"}})
        |> follow_redirect(conn, ~p"/tracking?tracking_number=TRK-DEMO-002")
    end
  end
end
