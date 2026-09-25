defmodule ShipmentTrackingDashboardWeb.StaffDashboardLive do
  use ShipmentTrackingDashboardWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, shipments: [])}
  end

  @impl true
  def handle_event("new_shipment", _, socket) do
    {:noreply, push_navigate(socket, to: "/staff/shipments/new")}
  end

  @impl true
  def handle_event("edit_shipment", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: "/staff/shipments/#{id}/edit")}
  end

  @impl true
  def handle_event("delete_shipment", %{"id" => _id}, socket) do
    # Delete shipment here

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto">
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-4xl font-bold text-slate-800">
            Shipment Management
          </h1>
        </div>

        <button
          phx-click="new_shipment"
          class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition"
        >
          + Create Shipment
        </button>
      </div>

      <div class="bg-white rounded-lg shadow overflow-hidden">
        <table class="min-w-full divide-y divide-slate-200">
          <thead class="bg-slate-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                Tracking Number
              </th>

              <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                Sender
              </th>

              <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                Recipient
              </th>

              <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                Status
              </th>

              <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                Created
              </th>

              <th class="px-6 py-3 text-right text-xs font-medium text-slate-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>

          <tbody class="bg-white divide-y divide-slate-200">
            <tr :for={shipment <- @shipments}>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-slate-900">
                {shipment.tracking_number}
              </td>

              <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-600">
                {shipment.sender_name}
              </td>

              <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-600">
                {shipment.recipient_name}
              </td>

              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-700">
                  {shipment.status}
                </span>
              </td>

              <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-600">
                {shipment.inserted_at}
              </td>

              <td class="px-6 py-4 whitespace-nowrap text-right space-x-2">
                <button
                  phx-click="edit_shipment"
                  phx-value-id={shipment.id}
                  class="px-3 py-1 bg-yellow-500 text-white rounded hover:bg-yellow-600"
                >
                  Edit
                </button>

                <button
                  phx-click="delete_shipment"
                  phx-value-id={shipment.id}
                  data-confirm="Are you sure?"
                  class="px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700"
                >
                  Delete
                </button>
              </td>
            </tr>

            <tr :if={Enum.empty?(@shipments)}>
              <td colspan="6" class="px-6 py-8 text-center text-slate-500">
                No shipments found.
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
