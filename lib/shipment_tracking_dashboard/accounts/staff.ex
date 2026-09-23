defmodule ShipmentTrackingDashboard.Accounts.Staff do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "staff" do
    field :email, :string
    field :role, :string
    field :password_hash, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(staff, attrs) do
    staff
    |> cast(attrs, [:email, :role, :password_hash])
    |> validate_required([:email, :role, :password_hash])
    |> unique_constraint(:email)
  end
end
