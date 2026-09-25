defmodule ShipmentTrackingDashboardWeb.ShipmentFormLive do
  use ShipmentTrackingDashboardWeb, :live_view

  alias ShipmentTrackingDashboard.Shipments
  alias ShipmentTrackingDashboard.Shipments.Shipment
  alias ShipmentTrackingDashboard.Shipments.Event

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
         |> assign(:form, to_form(changeset, as: :shipment))
         |> assign(:event_form, nil)}

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
             |> assign(:form, to_form(changeset, as: :shipment))
             |> assign(:event_form, blank_event_form())}
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

  @impl true
  def handle_event("validate_event", %{"event" => event_params}, socket) do
    changeset =
      %Event{}
      |> Event.changeset(event_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :event_form, to_form(changeset, as: :event))}
  end

  @impl true
  def handle_event("add_event", %{"event" => event_params}, socket) do
    case Shipments.create_event(socket.assigns.shipment, event_params) do
      {:ok, _event} ->
        # Re-fetch the shipment so the events list (and the form
        # underneath) reflects the newly added, append-only event.
        shipment = Shipments.get_shipment(socket.assigns.shipment.id)

        {:noreply,
         socket
         |> put_flash(:info, "Tracking event added")
         |> assign(:shipment, shipment)
         |> assign(:event_form, blank_event_form())}

      {:error, changeset} ->
        {:noreply, assign(socket, :event_form, to_form(changeset, as: :event))}
    end
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

  defp blank_event_form do
    %Event{}
    |> Event.changeset(%{})
    |> to_form(as: :event)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto">
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-slate-800">{@page_title}</h1>
        <p class="mt-2 text-slate-600">Enter the shipment details below.</p>
      </div>

      <div class="bg-white rounded-lg shadow p-8">
        <.form for={@form} phx-change="validate" phx-submit="save">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">Tracking Number</label>
              <.input
                field={@form[:tracking_number]}
                type="text"
                class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">Status</label>
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
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Internal Notes
              <span class="text-xs font-normal text-slate-400">(staff only — never shown to customers)</span>
            </label>
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

      <div :if={@live_action == :edit} class="bg-white rounded-lg shadow p-8 mt-8">
        <h2 class="text-xl font-bold text-slate-800 mb-1">Tracking Timeline</h2>
        <p class="text-sm text-slate-500 mb-6">
          Events are appended to the history and never overwrite prior entries.
        </p>

        <div :if={Enum.empty?(@shipment.events)} class="text-slate-500 text-sm mb-6">
          No tracking events yet.
        </div>

        <ul :if={@shipment.events != []} class="space-y-3 mb-8">
          <li :for={event <- Enum.reverse(@shipment.events)} class="border-l-2 border-blue-200 pl-4">
            <p class="text-sm font-medium text-slate-800">{event.message}</p>
            <p class="text-xs text-slate-500">
              {event.location} · {event.occurred_at}
            </p>
          </li>
        </ul>

        <h3 class="text-sm font-semibold text-slate-700 mb-3">Add tracking event</h3>

        <.form
          for={@event_form}
          phx-change="validate_event"
          phx-submit="add_event"
          class="grid grid-cols-1 md:grid-cols-2 gap-4"
        >
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">Occurred At</label>
            <.input
              field={@event_form[:occurred_at]}
              type="datetime-local"
              class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">Location</label>
            <.input
              field={@event_form[:location]}
              type="text"
              class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">Status</label>
            <select
              name={@event_form[:status].name}
              class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
            >
              <option value="">Select Status</option>
              <option value="created">Created</option>
              <option value="collected">Collected</option>
              <option value="out_for_delivery">Out For Delivery</option>
              <option value="delivered">Delivered</option>
              <option value="delayed">Delayed</option>
              <option value="cancelled">Cancelled</option>
            </select>
          </div>

          <div class="md:col-span-2">
            <label class="block text-sm font-medium text-slate-700 mb-2">Customer-facing message</label>
            <.input
              field={@event_form[:message]}
              type="textarea"
              rows="2"
              class="w-full rounded-md border border-slate-300 bg-white text-slate-900 px-3 py-2"
            />
          </div>

          <div class="md:col-span-2 flex justify-end">
            <button
              type="submit"
              phx-disable-with="Adding..."
              class="px-5 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              Add Event
            </button>
          </div>
        </.form>
      </div>
    </div>
    """
  end
end
