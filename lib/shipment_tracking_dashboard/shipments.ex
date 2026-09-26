defmodule ShipmentTrackingDashboard.Shipments do
  import Ecto.Query, warn: false

  alias ShipmentTrackingDashboard.Repo
  alias ShipmentTrackingDashboard.Shipments.Shipment
  alias ShipmentTrackingDashboard.Shipments.Event

  def create_shipment(attrs \\ %{}) do
    Shipment.create_shipment(%Shipment{}, attrs)
  end

  def change_shipment(%Shipment{} = shipment, attrs \\ %{}) do
    Shipment.changeset(shipment, attrs)
  end

  def initialise_shipment(%Shipment{} = shipment, attrs \\ %{}) do
    Shipment.unvalidated_changeset(shipment, attrs)
  end

  def update_shipment(%Shipment{} = shipment, attrs) do
    shipment
    |> Shipment.changeset(attrs)
    |> Repo.update()
  end

  def delete_shipment(%Shipment{} = shipment) do
    Repo.delete(shipment)
  end

  def get_shipment!(id) do
    Repo.get!(Shipment, id)
  end

  def get_shipment_by_tracking_number(tracking_number) do
    Shipment
    |> Repo.get_by(tracking_number: tracking_number)
    |> Repo.preload(
      events: from(e in ShipmentTrackingDashboard.Shipments.Event, order_by: [asc: e.occurred_at])
    )
  end

  def get_shipment(id) do
    Shipment
    |> Repo.get(id)
    |> Repo.preload(
      events: from(e in ShipmentTrackingDashboard.Shipments.Event, order_by: [asc: e.occurred_at])
    )
  end

  def list_shipments(filters \\ %{}) do
    Shipment
    |> maybe_filter_by_status(filters["status"])
    |> maybe_search_tracking_number(filters["q"])
    |> Repo.all()
    # Preloaded because the JSON API's shipment_json/1 always serializes
    # events for every shipment returned here — without this, GET
    # /api/staff/shipments would crash on the unloaded association.
    # The staff dashboard LiveView doesn't currently display events in
    # this list view, so this is some extra querying for that one caller,
    # but it's required for the API contract to work correctly.
    |> Repo.preload(events: from(e in Event, order_by: [asc: e.occurred_at]))
  end

  defp maybe_filter_by_status(query, nil), do: query
  defp maybe_filter_by_status(query, ""), do: query
  defp maybe_filter_by_status(query, status), do: from(s in query, where: s.status == ^status)

  defp maybe_search_tracking_number(query, nil), do: query
  defp maybe_search_tracking_number(query, ""), do: query

  defp maybe_search_tracking_number(query, q),
    do: from(s in query, where: ilike(s.tracking_number, ^"%#{q}%"))

  def create_event(%Shipment{} = shipment, attrs) do
    %Event{}
    |> Event.changeset(Map.put(attrs, "shipment_id", shipment.id))
    |> Repo.insert()
  end
end
