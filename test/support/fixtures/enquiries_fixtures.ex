defmodule ShipmentTrackingDashboard.EnquiriesFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `ShipmentTrackingDashboard.Enquiries` context.
  """

  alias ShipmentTrackingDashboard.Enquiries

  @doc """
  Generate an enquiry.

  Accepts an attrs map to override any default — most commonly
  `tracking_number` and `status` in tests that need a specific value.
  """
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
