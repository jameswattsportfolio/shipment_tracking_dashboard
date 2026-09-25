defmodule ShipmentTrackingDashboard.ShipmentsFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `ShipmentTrackingDashboard.Shipments` context.
  """

  alias ShipmentTrackingDashboard.Shipments

  @doc """
  Generate a shipment.

  Accepts an attrs map to override any default — most commonly
  `tracking_number` and `status` in tests that need a specific value.
  """
  def shipment_fixture(attrs \\ %{}) do
    unique_suffix = System.unique_integer([:positive])

    {:ok, shipment} =
      attrs
      |> Enum.into(%{
        "tracking_number" => "TRK-TEST-#{unique_suffix}",
        "status" => "created",
        "current_location" => "Test Depot",
        "origin" => "Manchester, UK",
        "destination" => "Bristol, UK",
        "service_level" => "standard",
        "package_count" => 1,
        "expected_delivery_date" => Date.add(Date.utc_today(), 3)
      })
      |> Shipments.create_shipment()

    shipment
  end

  @doc """
  Generate a shipment event, attached to a shipment.

  Pass `shipment_id` via attrs, or a `:shipment` struct — if neither is
  given, a new shipment is created for you.
  """
  def event_fixture(attrs \\ %{})

  def event_fixture(%{shipment: shipment} = attrs) do
    attrs
    |> Map.delete(:shipment)
    |> Map.put("shipment_id", shipment.id)
    |> event_fixture()
  end

  def event_fixture(attrs) do
    shipment_id = attrs["shipment_id"] || shipment_fixture().id

    {:ok, event} =
      attrs
      |> Enum.into(%{
        "shipment_id" => shipment_id,
        "occurred_at" => DateTime.utc_now() |> DateTime.truncate(:second),
        "location" => "Test Depot",
        "status" => "collected",
        "message" => "Shipment collected from sender"
      })
      |> then(fn attrs ->
        shipment = Shipments.get_shipment!(attrs["shipment_id"])
        Shipments.create_event(shipment, attrs)
      end)

    event
  end
end
