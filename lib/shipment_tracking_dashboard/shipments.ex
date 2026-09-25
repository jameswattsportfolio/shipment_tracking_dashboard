defmodule ShipmentTrackingDashboard.Shipments do
  import Ecto.Query, warn: false

  alias ShipmentTrackingDashboard.Repo
  alias ShipmentTrackingDashboard.Shipments.Shipment

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

  def list_shipments do
    Repo.all(Shipment)
  end
end
