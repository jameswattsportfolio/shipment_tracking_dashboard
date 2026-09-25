defmodule ShipmentTrackingDashboard.Shipments.Shipment do
  use Ecto.Schema
  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias ShipmentTrackingDashboard.Repo

  @statuses [
    :created,
    :collected,
    :out_for_delivery,
    :delivered,
    :delayed,
    :cancelled
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
    has_many :events, ShipmentTrackingDashboard.Shipments.Event

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

  def unvalidated_changeset(shipment, attrs) do
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
  end

  def create_shipment(shipment, attrs \\ %{}) do
    shipment
    |> changeset(attrs)
    |> IO.inspect()

    shipment
    |> changeset(attrs)
    |> Repo.insert()
  end
end
