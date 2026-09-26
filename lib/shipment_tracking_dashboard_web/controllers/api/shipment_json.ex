defmodule ShipmentTrackingDashboardWeb.Api.ShipmentJSON do
  def index(%{shipments: shipments}), do: %{data: Enum.map(shipments, &shipment_json/1)}
  def show(%{shipment: shipment}), do: %{data: shipment_json(shipment)}
  def event(%{event: event}), do: %{data: event_json(event)}

  defp shipment_json(shipment) do
    %{
      tracking_number: shipment.tracking_number,
      status: shipment.status,
      origin: shipment.origin,
      destination: shipment.destination,
      expected_delivery_date: shipment.expected_delivery_date,
      current_location: shipment.current_location,
      service_level: shipment.service_level,
      package_count: shipment.package_count,
      events: Enum.map(shipment.events || [], &event_json/1)
    }
  end

  defp event_json(event) do
    %{
      occurred_at: event.occurred_at,
      location: event.location,
      status: event.status,
      message: event.message
    }
  end
end
