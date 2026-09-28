defmodule ShipmentTrackingDashboardWeb.StaffDashboardLive do
  use ShipmentTrackingDashboardWeb, :live_view

  alias ShipmentTrackingDashboard.Shipments

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    filters = %{"status" => params["status"] || "", "q" => params["q"] || ""}

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> assign(:shipments, Shipments.list_shipments(filters))}
  end

  @impl true
  def handle_event("filter", params, socket) do
    query = %{status: params["status"] || "", q: params["q"] || ""}
    {:noreply, push_patch(socket, to: ~p"/staff/dashboard?#{query}")}
  end

  @impl true
  def handle_event("edit_shipment", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: "/staff/shipments/#{id}/edit")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto">
      <div class="flex items-center justify-between mb-8">
        <h1 class="text-4xl font-bold text-slate-800">Shipment Management</h1>

        <.link
          navigate="/staff/shipments/new"
          class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition"
        >
          + Create Shipment
        </.link>
      </div>

      <form phx-change="filter" class="mb-6 flex flex-wrap gap-3 items-end">
        <div>
          <label for="q" class="block text-sm font-medium text-slate-700 mb-1">
            Search by tracking number
          </label>
          <input
            type="text"
            id="q"
            name="q"
            value={@filters["q"]}
            placeholder="TRK-DEMO-001"
            class="rounded-md border border-slate-300 px-3 py-2 text-sm"
          />
        </div>

        <div>
          <label for="status" class="block text-sm font-medium text-slate-700 mb-1">
            Status
          </label>
          <select
            id="status"
            name="status"
            class="rounded-md border border-slate-300 px-3 py-2 text-sm bg-slate-100  text-slate-500"
          >
            <option value="" selected={@filters["status"] == ""}>All statuses</option>
            <option value="created" selected={@filters["status"] == "created"}>Created</option>
            <option value="collected" selected={@filters["status"] == "collected"}>Collected</option>
            <option value="out_for_delivery" selected={@filters["status"] == "out_for_delivery"}>
              Out For Delivery
            </option>
            <option value="delivered" selected={@filters["status"] == "delivered"}>Delivered</option>
            <option value="delayed" selected={@filters["status"] == "delayed"}>Delayed</option>
            <option value="cancelled" selected={@filters["status"] == "cancelled"}>Cancelled</option>
          </select>
        </div>
      </form>

      <div class="bg-white rounded-lg shadow overflow-x-auto">
        <table class="min-w-full divide-y divide-slate-200">
          <thead class="bg-slate-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                Tracking Number
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                Route
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                Status
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                ETA
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                Last Update
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
                {shipment.origin} → {shipment.destination}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-700">
                  {shipment.status}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-600">
                {shipment.expected_delivery_date}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-600">
                {shipment.updated_at}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right">
                <button
                  phx-click="edit_shipment"
                  phx-value-id={shipment.id}
                  class="px-3 py-1 bg-yellow-500 text-white rounded hover:bg-yellow-600"
                >
                  Edit
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
