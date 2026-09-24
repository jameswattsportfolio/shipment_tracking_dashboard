defmodule ShipmentTrackingDashboardWeb.TrackingHTML do
  use ShipmentTrackingDashboardWeb, :html

  embed_templates "tracking_html/*"

  # def mount(_params, _session, socket) do
  #   {:ok, assign(socket, active_tab: :tracking)}
  # end

  # def handle_event("switch_tab", %{"tab" => "tracking"}, socket) do
  #   IO.inspect("Switching tab in tracking html ex")
  #   {:noreply, assign(socket, active_tab: :tracking)}
  # end
end
