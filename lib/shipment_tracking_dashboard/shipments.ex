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
    |> Repo.all()
  end

  defp maybe_filter_by_status(query, nil), do: query
  defp maybe_filter_by_status(query, ""), do: query
  defp maybe_filter_by_status(query, status), do: from(s in query, where: s.status == ^status)

  def create_event(%Shipment{} = shipment, attrs) do
    %Event{}
    |> Event.changeset(Map.put(attrs, "shipment_id", shipment.id))
    |> Repo.insert()
  end
end
