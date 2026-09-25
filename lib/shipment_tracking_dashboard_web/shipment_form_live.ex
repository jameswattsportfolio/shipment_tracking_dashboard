defmodule ShipmentTrackingDashboardWeb.ShipmentFormLive do
  use ShipmentTrackingDashboardWeb, :live_view

  alias ShipmentTrackingDashboard.Shipments
  alias ShipmentTrackingDashboard.Shipments.Shipment

  @impl true
  def mount(_params, _session, socket) do
    changeset =
      Shipments.initialise_shipment(%Shipment{})
      |> Map.from_struct()

    {:ok,
     socket
     |> assign(:page_title, "New Shipment")
     |> assign(:shipment, %Shipment{})
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    case socket.assigns.live_action do
      :new ->
        {:noreply, assign(socket, page_title: "New Shipment")}

      :edit ->
        {:noreply, assign(socket, page_title: "Edit Shipment")}
    end
  end

  @impl true
  def handle_event("validate", params, socket) do
    changeset =
      socket.assigns.shipment
      |> Shipments.change_shipment(params)
      |> Map.put(:action, :validate)

    IO.inspect(changeset)

    {:noreply, assign(socket, :form, changeset)}
  end

  @impl true
  def handle_event("save", shipment_params, socket) do
    IO.inspect("shipment_params")
    IO.inspect(shipment_params)

    case Shipments.create_shipment(shipment_params) do
      {:ok, _shipment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Shipment created successfully")
         |> push_navigate(to: "/staff/dashboard")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto">
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-slate-800">
          {@page_title}
        </h1>

        <p class="mt-2 text-slate-600">
          Enter the shipment details below.
        </p>
      </div>

      <div class="bg-white rounded-lg shadow p-8">
        <.form
          for={@form}
          phx-submit="save"
        >
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">
                Tracking Number
              </label>

              <.input
                type="text"
                name={@form[:tracking_number].name}
                value={@form[:tracking_number].value}
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />

              <div
                :for={error <- @form[:tracking_number].errors}
                class="mt-1 text-sm text-red-600"
              >
                {elem(error, 0)}
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">
                Status
              </label>

              <select
                name={@form[:status].name}
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              >
                <option value="">Select Status</option>
                <option
                  value="created"
                  selected={@form[:status].value == "created"}
                >
                  Created
                </option>

                <option
                  value="out_for_delivery"
                  selected={@form[:status].value == "out_for_delivery"}
                >
                  Out For Delivery
                </option>

                <option
                  value="delivered"
                  selected={@form[:status].value == "delivered"}
                >
                  Delivered
                </option>

                <option
                  value="delayed"
                  selected={@form[:status].value == "delayed"}
                >
                  Delayed
                </option>

                <option
                  value="cancelled"
                  selected={@form[:status].value == "cancelled"}
                >
                  Cancelled
                </option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">
                Current Location
              </label>

              <.input
                type="text"
                name={@form[:current_location].name}
                value={@form[:current_location].value}
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">
                Origin
              </label>

              <.input
                type="text"
                name={@form[:origin].name}
                value={@form[:origin].value}
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">
                Destination
              </label>

              <.input
                type="text"
                name={@form[:destination].name}
                value={@form[:destination].value}
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">
                Service Level
              </label>

              <.input
                type="text"
                name={@form[:service_level].name}
                value={@form[:service_level].value}
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">
                Total Weight (kg)
              </label>

              <.input
                type="number"
                step="0.01"
                name={@form[:total_weight].name}
                value={@form[:total_weight].value}
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">
                Package Count
              </label>

              <.input
                type="number"
                name={@form[:package_count].name}
                value={@form[:package_count].value}
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">
                Expected Delivery Date
              </label>

              <.input
                type="date"
                name={@form[:expected_delivery_date].name}
                value={@form[:expected_delivery_date].value}
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">
                Actual Delivery Date
              </label>

              <.input
                type="date"
                name={@form[:actual_delivery_date].name}
                value={@form[:actual_delivery_date].value}
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>
          </div>

          <div class="mt-6">
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Shipment Notes
            </label>

            <textarea
              name={@form[:shipment_notes].name}
              rows="4"
              class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
            ><%= @form[:shipment_notes].value %></textarea>
          </div>

          <div class="mt-8 flex justify-end gap-3">
            <.link
              navigate="/staff"
              class="px-4 py-2 border border-slate-300 rounded-md text-slate-700 hover:bg-slate-100"
            >
              Cancel
            </.link>

            <button
              type="submit"
              class="px-5 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              Save Shipment
            </button>
          </div>
        </.form>
      </div>
    </div>
    """
  end
end
