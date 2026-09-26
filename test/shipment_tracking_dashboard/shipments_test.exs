defmodule ShipmentTrackingDashboard.ShipmentsTest do
  use ShipmentTrackingDashboard.DataCase, async: true

  alias ShipmentTrackingDashboard.Shipments

  import ShipmentTrackingDashboard.ShipmentsFixtures

  describe "create_event/2" do
    test "adds an event to a shipment's timeline" do
      shipment = shipment_fixture()

      {:ok, event} =
        Shipments.create_event(shipment, %{
          "occurred_at" => DateTime.utc_now() |> DateTime.truncate(:second),
          "location" => "Bristol Depot",
          "status" => "collected",
          "message" => "Shipment collected from sender"
        })

      assert event.shipment_id == shipment.id
      assert event.location == "Bristol Depot"
    end

    test "rejects an event missing required fields" do
      shipment = shipment_fixture()

      {:error, changeset} = Shipments.create_event(shipment, %{"location" => "Bristol Depot"})

      assert %{occurred_at: ["can't be blank"]} = errors_on(changeset)
      assert %{status: ["can't be blank"]} = errors_on(changeset)
      assert %{message: ["can't be blank"]} = errors_on(changeset)
    end

    test "adding a new event never removes or alters prior events" do
      shipment = shipment_fixture()

      {:ok, first} =
        Shipments.create_event(shipment, %{
          "occurred_at" => ~U[2026-09-20 09:00:00Z],
          "location" => "Manchester Depot",
          "status" => "collected",
          "message" => "Shipment collected from sender"
        })

      {:ok, second} =
        Shipments.create_event(shipment, %{
          "occurred_at" => ~U[2026-09-22 14:00:00Z],
          "location" => "Bristol Depot",
          "status" => "out_for_delivery",
          "message" => "Out for delivery"
        })

      fetched = Shipments.get_shipment(shipment.id)

      assert length(fetched.events) == 2
      assert Enum.map(fetched.events, & &1.id) == [first.id, second.id]

      # Original event content is untouched by the later insert
      original = Enum.find(fetched.events, &(&1.id == first.id))
      assert original.location == "Manchester Depot"
      assert original.message == "Shipment collected from sender"
    end

    test "events are returned in chronological order, oldest first" do
      shipment = shipment_fixture()

      {:ok, later} =
        Shipments.create_event(shipment, %{
          "occurred_at" => ~U[2026-09-22 10:00:00Z],
          "location" => "Bristol Depot",
          "status" => "out_for_delivery",
          "message" => "Out for delivery"
        })

      {:ok, earlier} =
        Shipments.create_event(shipment, %{
          "occurred_at" => ~U[2026-09-20 08:00:00Z],
          "location" => "Manchester Depot",
          "status" => "collected",
          "message" => "Shipment collected from sender"
        })

      fetched = Shipments.get_shipment(shipment.id)

      # Inserted out of chronological order (later first), but the query
      # orders by occurred_at, so the fetched list should still read
      # earliest -> latest regardless of insert order.
      assert Enum.map(fetched.events, & &1.id) == [earlier.id, later.id]
    end
  end

  describe "get_shipment_by_tracking_number/1" do
    test "preloads events for public tracking lookups" do
      shipment = shipment_fixture(%{"tracking_number" => "TRK-DEMO-001"})
      event_fixture(%{"shipment_id" => shipment.id})

      fetched = Shipments.get_shipment_by_tracking_number("TRK-DEMO-001")

      assert length(fetched.events) == 1
    end

    test "returns nil for an unknown tracking number" do
      assert Shipments.get_shipment_by_tracking_number("TRK-DOES-NOT-EXIST") == nil
    end
  end
end
