defmodule ShipmentTrackingDashboardWeb.TrackingLive do
  use ShipmentTrackingDashboardWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    IO.inspect("TrackingLive.ex - live folder")

    {:ok,
     assign(socket,
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
    <div class="max-w-5xl mx-auto">
      <div class="text-center mb-10">
        <h1 class="text-4xl font-bold text-slate-800">
          Track Your Shipment
        </h1>
        <p class="mt-3 text-slate-600">
          Enter your tracking number below to view shipment updates.
        </p>
      </div>

      <div class="bg-white shadow rounded-lg p-6 mb-8">
        <.form
          for={%{}}
          as={:tracking}
          phx-submit="search"
          class="flex gap-4"
        >
          <input
            type="text"
            name="tracking[tracking_number]"
            placeholder="e.g. TRK-DEMO-001"
            class="text-slate-800 placeholder:text-slate-400 flex-1 rounded-lg border border-slate-300 px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />

          <button
            type="submit"
            class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg"
          >
            Track
          </button>
        </.form>
      </div>

      <%= if @error do %>
        <div class="bg-red-100 border border-red-300 text-red-700 rounded-lg p-4">
          {@error}
        </div>
      <% end %>

      <%= if @shipment do %>
        <div class="bg-white rounded-lg shadow p-6 mb-6 text-slate-800">
          <div class="flex justify-between items-center mb-6">
            <div>
              <h2 class="text-2xl font-bold">
                {@shipment.tracking_number}
              </h2>

              <p class="text-slate-500">
                Shipment Details
              </p>
            </div>

            <span class="bg-blue-100 text-blue-700 px-4 py-2 rounded-full font-semibold">
              {@shipment.status}
            </span>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h3 class="font-semibold mb-2 text-slate-800">
                Origin
              </h3>
              <p class="text-slate-700">
                {@shipment.origin}
              </p>
            </div>

            <div>
              <h3 class="font-semibold mb-2 text-slate-800">
                Destination
              </h3>
              <p class="text-slate-700">
                {@shipment.destination}
              </p>
            </div>

            <div>
              <h3 class="font-semibold mb-2 text-slate-800">
                Current Location
              </h3>
              <p class="text-slate-700">
                {@shipment.current_location}
              </p>
            </div>

            <div>
              <h3 class="font-semibold mb-2 text-slate-800">
                Estimated Delivery
              </h3>
              <p class="text-slate-700">
                29 September 2026
              </p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6 text-slate-800">
          <h3 class="text-xl font-bold mb-6">
            Tracking Timeline
          </h3>

          <div class="space-y-6">
            <div class="flex gap-4">
              <div class="w-4 h-4 rounded-full bg-green-500 mt-2"></div>

              <div>
                <p class="font-semibold text-slate-800">
                  Arrived at Birmingham Hub
                </p>

                <p class="text-sm text-slate-500">
                  Birmingham
                </p>

                <p class="text-xs text-slate-400">
                  22 Sep 2026 09:15
                </p>
              </div>
            </div>

            <div class="flex gap-4">
              <div class="w-4 h-4 rounded-full bg-blue-500 mt-2"></div>

              <div>
                <p class="font-semibold text-slate-800">
                  Departed Coventry Distribution Centre
                </p>

                <p class="text-sm text-slate-500">
                  Coventry
                </p>

                <p class="text-xs text-slate-400">
                  21 Sep 2026 18:45
                </p>
              </div>
            </div>

            <div class="flex gap-4">
              <div class="w-4 h-4 rounded-full bg-blue-500 mt-2"></div>

              <div>
                <p class="font-semibold text-slate-800">
                  Shipment Collected
                </p>

                <p class="text-sm text-slate-500">
                  London
                </p>

                <p class="text-xs text-slate-400">
                  21 Sep 2026 09:00
                </p>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
