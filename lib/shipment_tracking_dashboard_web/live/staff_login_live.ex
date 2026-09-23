defmodule ShipmentTrackingDashboardWeb.StaffLoginLive do
  use ShipmentTrackingDashboardWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    IO.puts("StaffLoginLive.ex - live folder")

    {:ok,
     assign(socket,
       active_tab: :staff_login
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-md mx-auto">
      <div class="text-center mb-10">
        <h1 class="text-4xl font-bold text-slate-800">
          Staff Login
        </h1>

        <p class="mt-3 text-slate-600">
          Sign in to access the shipment management dashboard.
        </p>
      </div>

      <div class="bg-white shadow rounded-lg p-8">
        <form class="space-y-6">
          <div>
            <label
              for="email"
              class="block text-sm font-semibold text-slate-700 mb-2"
            >
              Email Address
            </label>

            <input
              id="email"
              type="email"
              name="email"
              placeholder="you@example.com"
              class="w-full rounded-lg border border-slate-300 px-4 py-3 text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <div>
            <div class="flex justify-between items-center mb-2">
              <label
                for="password"
                class="block text-sm font-semibold text-slate-700"
              >
                Password
              </label>
            </div>

            <input
              id="password"
              type="password"
              name="password"
              placeholder="Enter your password"
              class="w-full rounded-lg border border-slate-300 px-4 py-3 text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <button
            type="submit"
            class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold px-6 py-3 rounded-lg transition"
          >
            Sign In
          </button>
        </form>
      </div>
    </div>
    """
  end
end
