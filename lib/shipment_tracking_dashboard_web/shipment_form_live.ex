defmodule ShipmentTrackingDashboardWeb.ShipmentFormLive do
  use ShipmentTrackingDashboardWeb, :live_view

  alias ShipmentTrackingDashboard.Shipments
  alias ShipmentTrackingDashboard.Shipments.Shipment

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    case socket.assigns.live_action do
      :new ->
        changeset = Shipments.initialise_shipment(%Shipment{})

        {:noreply,
         socket
         |> assign(:page_title, "New Shipment")
         |> assign(:shipment, %Shipment{})
         |> assign(:form, to_form(changeset, as: :shipment))}

      :edit ->
        case Shipments.get_shipment(params["id"]) do
          nil ->
            {:noreply,
             socket
             |> put_flash(:error, "Shipment not found")
             |> push_navigate(to: "/staff/dashboard")}

          shipment ->
            changeset = Shipments.change_shipment(shipment)

            {:noreply,
             socket
             |> assign(:page_title, "Edit Shipment")
             |> assign(:shipment, shipment)
             |> assign(:form, to_form(changeset, as: :shipment))}
        end
    end
  end

  @impl true
  def handle_event("validate", %{"shipment" => shipment_params}, socket) do
    changeset =
      socket.assigns.shipment
      |> Shipments.change_shipment(shipment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: :shipment))}
  end

  @impl true
  def handle_event("save", %{"shipment" => shipment_params}, socket) do
    save_shipment(socket, socket.assigns.live_action, shipment_params)
  end

  defp save_shipment(socket, :new, shipment_params) do
    case Shipments.create_shipment(shipment_params) do
      {:ok, _shipment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Shipment created successfully")
         |> push_navigate(to: "/staff/dashboard")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :shipment))}
    end
  end

  defp save_shipment(socket, :edit, shipment_params) do
    case Shipments.update_shipment(socket.assigns.shipment, shipment_params) do
      {:ok, _shipment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Shipment updated successfully")
         |> push_navigate(to: "/staff/dashboard")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :shipment))}
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
        <.form for={@form} phx-change="validate" phx-submit="save">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">
                Tracking Number
              </label>
              <.input
                field={@form[:tracking_number]}
                type="text"
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
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
                <option value="created" selected={to_string(@form[:status].value) == "created"}>
                  Created
                </option>
                <option value="collected" selected={to_string(@form[:status].value) == "collected"}>
                  Collected
                </option>
                <option
                  value="out_for_delivery"
                  selected={to_string(@form[:status].value) == "out_for_delivery"}
                >
                  Out For Delivery
                </option>
                <option value="delivered" selected={to_string(@form[:status].value) == "delivered"}>
                  Delivered
                </option>
                <option value="delayed" selected={to_string(@form[:status].value) == "delayed"}>
                  Delayed
                </option>
                <option value="cancelled" selected={to_string(@form[:status].value) == "cancelled"}>
                  Cancelled
                </option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">Current Location</label>
              <.input
                field={@form[:current_location]}
                type="text"
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">Origin</label>
              <.input
                field={@form[:origin]}
                type="text"
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">Destination</label>
              <.input
                field={@form[:destination]}
                type="text"
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">Service Level</label>
              <.input
                field={@form[:service_level]}
                type="text"
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">Total Weight (kg)</label>
              <.input
                field={@form[:total_weight]}
                type="number"
                step="0.01"
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">Package Count</label>
              <.input
                field={@form[:package_count]}
                type="number"
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">Expected Delivery Date</label>
              <.input
                field={@form[:expected_delivery_date]}
                type="date"
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">Actual Delivery Date</label>
              <.input
                field={@form[:actual_delivery_date]}
                type="date"
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>
          </div>

          <div class="mt-6">
            <label class="block text-sm font-medium text-slate-700 mb-2">Shipment Notes</label>
            <.input
              field={@form[:shipment_notes]}
              type="textarea"
              rows="4"
              class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
            />
          </div>

          <div class="mt-8 flex justify-end gap-3">
            <.link
              navigate="/staff/dashboard"
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
