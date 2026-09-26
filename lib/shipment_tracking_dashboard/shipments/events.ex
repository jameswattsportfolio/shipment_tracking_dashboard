defmodule ShipmentTrackingDashboard.Shipments.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "shipment_events" do
    field :occurred_at, :utc_datetime
    field :location, :string

    field :status, Ecto.Enum,
      values: [
        :created,
        :collected,
        :out_for_delivery,
        :delivered,
        :delayed,
        :cancelled
      ]

    field :message, :string

    belongs_to :shipment, ShipmentTrackingDashboard.Shipments.Shipment

    timestamps(type: :utc_datetime)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:occurred_at, :location, :status, :message, :shipment_id])
    |> validate_required([:occurred_at, :location, :status, :message, :shipment_id])
  end
end
