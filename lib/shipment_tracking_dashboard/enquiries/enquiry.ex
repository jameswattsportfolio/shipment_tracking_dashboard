defmodule ShipmentTrackingDashboard.Enquiries.Enquiry do
  use Ecto.Schema
  import Ecto.Changeset

  @categories [:delivery_delay, :damaged_item, :wrong_address, :missing_item, :general]
  @statuses [:open, :resolved]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "enquiries" do
    field :tracking_number, :string
    field :category, Ecto.Enum, values: @categories
    field :message, :string
    field :status, Ecto.Enum, values: @statuses, default: :open

    timestamps(type: :utc_datetime)
  end

  @doc "Used for the public enquiry-submission form — customers only set these three fields."
  def create_changeset(enquiry, attrs) do
    enquiry
    |> cast(attrs, [:tracking_number, :category, :message])
    |> validate_required([:tracking_number, :category, :message])
    |> validate_length(:tracking_number, min: 1, max: 50)
    |> validate_length(:message, min: 1, max: 2000)
  end

  @doc "Used by staff — only status can be changed, never the original submission content."
  def status_changeset(enquiry, attrs) do
    enquiry
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
