defmodule ShipmentTrackingDashboardWeb.StaffDashboardLive do
  use ShipmentTrackingDashboardWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto">
      <div class="mb-10">
        <h1 class="text-4xl font-bold text-slate-800">
          Staff Dashboard
        </h1>

        <p class="mt-3 text-slate-600">
          Manage shipments and monitor deliveries.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="bg-white rounded-lg shadow p-6">
          <h2 class="text-lg font-semibold text-slate-800">
            Active Shipments
          </h2>

          <p class="mt-3 text-3xl font-bold text-blue-600">
            0
          </p>
        </div>

        <div class="bg-white rounded-lg shadow p-6">
          <h2 class="text-lg font-semibold text-slate-800">
            In Transit
          </h2>

          <p class="mt-3 text-3xl font-bold text-blue-600">
            0
          </p>
        </div>

        <div class="bg-white rounded-lg shadow p-6">
          <h2 class="text-lg font-semibold text-slate-800">
            Delivered
          </h2>

          <p class="mt-3 text-3xl font-bold text-green-600">
            0
          </p>
        </div>
      </div>
    </div>
    """
  end
end
