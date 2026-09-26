defmodule ShipmentTrackingDashboardWeb.Api.EnquiryJSON do
  def index(%{enquiries: enquiries}), do: %{data: Enum.map(enquiries, &enquiry_json/1)}
  def show(%{enquiry: enquiry}), do: %{data: enquiry_json(enquiry)}

  defp enquiry_json(enquiry) do
    %{
      id: enquiry.id,
      tracking_number: enquiry.tracking_number,
      category: enquiry.category,
      message: enquiry.message,
      status: enquiry.status,
      inserted_at: enquiry.inserted_at
    }
  end
end
