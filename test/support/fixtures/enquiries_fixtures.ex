defmodule ShipmentTrackingDashboard.EnquiriesFixtures do
  alias ShipmentTrackingDashboard.Enquiries

  def enquiry_fixture(attrs \\ %{}) do
    {:ok, enquiry} =
      attrs
      |> Enum.into(%{
        "tracking_number" => "TRK-TEST-#{System.unique_integer([:positive])}",
        "category" => "general",
        "message" => "Where is my shipment, please?"
      })
      |> Enquiries.create_enquiry()

    enquiry
  end
end
