defmodule ShipmentTracker.Shipping.Shipment do
  use Ecto.Schema

  import Ecto.Changeset

  @statuses [
    :created,
    :collected,
    :in_transit,
    :out_for_delivery,
    :delivered,
    :delayed,
    :exception
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "shipments" do
    field :tracking_number, :string
    field :status, Ecto.Enum, values: @statuses, default: :created
    field :current_location, :string
    field :origin, :string
    field :destination, :string
    field :service_level, :string
    field :total_weight, :decimal
    field :package_count, :integer
    field :expected_delivery_date, :date
    field :actual_delivery_date, :date
    field :shipment_notes, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(shipment, attrs) do
    shipment
    |> cast(attrs, [
      :tracking_number,
      :status,
      :current_location,
      :origin,
      :destination,
      :service_level,
      :total_weight,
      :package_count,
      :expected_delivery_date,
      :actual_delivery_date,
      :shipment_notes
    ])
    |> validate_required([
      :tracking_number,
      :status,
      :current_location,
      :origin,
      :destination
    ])
    |> unique_constraint(:tracking_number)
  end
end
