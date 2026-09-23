defmodule ShipmentTrackingDashboardWeb.TrackingLive do
  use ShipmentTrackingDashboardWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    IO.puts("TrackingLive.ex - live folder")

    {:ok,
     assign(socket,
       active_tab: :tracking,
       tracking_number: "",
       shipment: nil,
       error: nil
     )}
  end

  @impl true
  def handle_event("search", %{"tracking" => %{"tracking_number" => tracking_number}}, socket) do
    # Replace this with a database lookup later
    shipment =
      if tracking_number == "TRK-DEMO-001" do
        %{
          tracking_number: "TRK-DEMO-001",
          status: "In Transit",
          origin: "London",
          destination: "Manchester",
          current_location: "Birmingham"
        }
      else
        nil
      end

    if shipment do
      {:noreply,
       assign(socket,
         shipment: shipment,
         error: nil
       )}
    else
      {:noreply,
       assign(socket,
         shipment: nil,
         error: "Shipment not found."
       )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    This is the tracking page

    Enter your tracking number
    """
  end
end
