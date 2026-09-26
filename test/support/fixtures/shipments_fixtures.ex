defmodule ShipmentTrackingDashboard.ShipmentsFixtures do
  alias ShipmentTrackingDashboard.Shipments

  def shipment_fixture(attrs \\ %{}) do
    unique_suffix = System.unique_integer([:positive])
    attrs = stringify_keys(attrs)

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

  def event_fixture(attrs \\ %{})

  def event_fixture(%{shipment: shipment} = attrs) do
    attrs
    |> Map.delete(:shipment)
    |> Map.put("shipment_id", shipment.id)
    |> event_fixture()
  end

  def event_fixture(attrs) do
    attrs = stringify_keys(attrs)
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

  defp stringify_keys(attrs) do
    Map.new(attrs, fn {k, v} -> {to_string(k), v} end)
  end
end
