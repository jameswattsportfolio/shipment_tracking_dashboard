defmodule ShipmentTrackingDashboard.Enquiries do
  import Ecto.Query, warn: false

  alias ShipmentTrackingDashboard.Repo
  alias ShipmentTrackingDashboard.Enquiries.Enquiry

  def create_enquiry(attrs) do
    %Enquiry{}
    |> Enquiry.create_changeset(attrs)
    |> Repo.insert()
  end

  def get_enquiry(id), do: Repo.get(Enquiry, id)

  def list_enquiries(filters \\ %{}) do
    Enquiry
    |> maybe_filter_by_status(filters["status"])
    |> order_by([e], desc: e.inserted_at)
    |> Repo.all()
  end

  defp maybe_filter_by_status(query, nil), do: query
  defp maybe_filter_by_status(query, ""), do: query
  defp maybe_filter_by_status(query, status), do: from(e in query, where: e.status == ^status)

  def update_enquiry_status(%Enquiry{} = enquiry, attrs) do
    enquiry
    |> Enquiry.status_changeset(attrs)
    |> Repo.update()
  end

  def change_enquiry(%Enquiry{} = enquiry, attrs \\ %{}) do
    Enquiry.create_changeset(enquiry, attrs)
  end
end
