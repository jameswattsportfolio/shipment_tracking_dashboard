defmodule ShipmentTrackingDashboardWeb.TrackingLive do
  use ShipmentTrackingDashboardWeb, :live_view

  alias ShipmentTrackingDashboard.Shipments
  alias ShipmentTrackingDashboard.Enquiries
  alias ShipmentTrackingDashboard.Enquiries.Enquiry

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       shipment: nil,
       error: nil,
       searched: false,
       enquiry_form: nil,
       enquiry_sent: false
     )}
  end

  @impl true
  def handle_params(%{"tracking_number" => tracking_number}, _uri, socket) do
    {:noreply, do_search(socket, tracking_number)}
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  @impl true
  def handle_event("search", %{"tracking" => %{"tracking_number" => tracking_number}}, socket) do
    case String.trim(tracking_number) do
      "" ->
        {:noreply,
         assign(socket, shipment: nil, searched: true, error: "Please enter a tracking number.")}

      trimmed ->
        {:noreply, push_patch(socket, to: ~p"/tracking?#{[tracking_number: trimmed]}")}
    end
  end

  @impl true
  def handle_event("validate_enquiry", %{"enquiry" => enquiry_params}, socket) do
    changeset =
      %Enquiry{}
      |> Enquiries.change_enquiry(enquiry_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :enquiry_form, to_form(changeset, as: :enquiry))}
  end

  @impl true
  def handle_event("submit_enquiry", %{"enquiry" => enquiry_params}, socket) do
    case Enquiries.create_enquiry(enquiry_params) do
      {:ok, _enquiry} ->
        {:noreply,
         socket
         |> assign(:enquiry_sent, true)
         |> assign(:enquiry_form, blank_enquiry_form(socket.assigns.shipment))}

      {:error, changeset} ->
        {:noreply, assign(socket, :enquiry_form, to_form(changeset, as: :enquiry))}
    end
  end

  defp do_search(socket, tracking_number) do
    case Shipments.get_shipment_by_tracking_number(tracking_number) do
      nil ->
        assign(socket,
          shipment: nil,
          searched: true,
          error: "We couldn't find a shipment with that tracking number.",
          enquiry_form: nil
        )

      shipment ->
        assign(socket,
          shipment: shipment,
          searched: true,
          error: nil,
          enquiry_sent: false,
          enquiry_form: blank_enquiry_form(shipment)
        )
    end
  end

  defp blank_enquiry_form(nil), do: nil

  defp blank_enquiry_form(shipment) do
    %Enquiry{}
    |> Enquiries.change_enquiry(%{"tracking_number" => shipment.tracking_number})
    |> to_form(as: :enquiry)
  end

  defp status_badge_class(:delivered), do: "bg-green-100 text-green-700"
  defp status_badge_class(:delayed), do: "bg-amber-100 text-amber-800"
  defp status_badge_class(:cancelled), do: "bg-red-100 text-red-700"
  defp status_badge_class(_), do: "bg-blue-100 text-blue-700"

  defp status_label(:out_for_delivery), do: "Out for Delivery"
  defp status_label(status), do: status |> to_string() |> String.capitalize()

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-5xl mx-auto">
      <div class="text-center mb-10">
        <h1 class="text-4xl font-bold text-slate-800">Track Your Shipment</h1>
        <p class="mt-3 text-slate-600">Enter your tracking number below to view shipment updates.</p>
      </div>

      <div class="bg-white shadow rounded-lg p-6 mb-8">
        <.form for={%{}} as={:tracking} phx-submit="search" class="flex gap-4">
          <input
            type="text"
            name="tracking[tracking_number]"
            value={@shipment && @shipment.tracking_number}
            placeholder="e.g. TRK-DEMO-001"
            class="text-slate-800 placeholder:text-slate-400 flex-1 rounded-lg border border-slate-300 px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button
            type="submit"
            phx-disable-with="Searching..."
            class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg disabled:opacity-60"
          >
            Track
          </button>
        </.form>
      </div>

      <div :if={@error} class="bg-red-100 border border-red-300 text-red-700 rounded-lg p-4 mb-6">
        {@error}
      </div>

      <div :if={@shipment} class="bg-white rounded-lg shadow p-6 mb-6 text-slate-800">
        <div class="flex justify-between items-center mb-6">
          <div>
            <h2 class="text-2xl font-bold">{@shipment.tracking_number}</h2>
            <p class="text-slate-500">Shipment Details</p>
          </div>
          <span class={"px-4 py-2 rounded-full font-semibold #{status_badge_class(@shipment.status)}"}>
            {status_label(@shipment.status)}
          </span>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h3 class="font-semibold mb-2 text-slate-800">Origin</h3>
            <p class="text-slate-700">{@shipment.origin}</p>
          </div>
          <div>
            <h3 class="font-semibold mb-2 text-slate-800">Destination</h3>
            <p class="text-slate-700">{@shipment.destination}</p>
          </div>
          <div>
            <h3 class="font-semibold mb-2 text-slate-800">Current Location</h3>
            <p class="text-slate-700">{@shipment.current_location}</p>
          </div>
          <div>
            <h3 class="font-semibold mb-2 text-slate-800">Estimated Delivery</h3>
            <p class="text-slate-700">{@shipment.expected_delivery_date || "Not yet available"}</p>
          </div>
        </div>
      </div>

      <div :if={@shipment} class="bg-white rounded-lg shadow p-6 mb-6 text-slate-800">
        <h3 class="text-xl font-bold mb-6">Tracking Timeline</h3>

        <div :if={Enum.empty?(@shipment.events)} class="text-slate-500 text-sm">
          No tracking events yet — check back soon for updates.
        </div>

        <div :if={@shipment.events != []} class="space-y-6">
          <div
            :for={{event, index} <- Enum.with_index(Enum.reverse(@shipment.events))}
            class="flex gap-4"
          >
            <div class={"w-4 h-4 rounded-full mt-2 #{if index == 0, do: "bg-green-500", else: "bg-blue-500"}"}>
            </div>
            <div>
              <p class="font-semibold text-slate-800">
                {event.message}
                <span :if={index == 0} class="ml-2 text-xs font-normal text-green-600">(Latest)</span>
              </p>
              <p class="text-sm text-slate-500">{event.location}</p>
              <p class="text-xs text-slate-400">{event.occurred_at}</p>
            </div>
          </div>
        </div>
      </div>

      <div :if={@shipment} class="bg-white rounded-lg shadow p-6 text-slate-800">
        <h3 class="text-xl font-bold mb-2">Have a question about this shipment?</h3>
        <p class="text-slate-500 text-sm mb-6">
          Send us an enquiry and our team will follow up.
        </p>

        <div
          :if={@enquiry_sent}
          class="bg-green-50 border border-green-300 text-green-800 rounded-lg p-4 mb-4"
        >
          Thanks — your enquiry has been submitted. We'll be in touch if we need more information.
        </div>

        <.form
          :if={@enquiry_form}
          for={@enquiry_form}
          phx-change="validate_enquiry"
          phx-submit="submit_enquiry"
          class="space-y-4"
        >
          <input
            type="hidden"
            name={@enquiry_form[:tracking_number].name}
            value={@shipment.tracking_number}
          />

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">Category</label>
            <select
              name={@enquiry_form[:category].name}
              class="w-full rounded-md border border-slate-300 px-3 py-2 text-slate-900"
            >
              <option value="">Select a category</option>
              <option
                value="delivery_delay"
                selected={to_string(@enquiry_form[:category].value) == "delivery_delay"}
              >
                Delivery delay
              </option>
              <option
                value="damaged_item"
                selected={to_string(@enquiry_form[:category].value) == "damaged_item"}
              >
                Damaged item
              </option>
              <option
                value="wrong_address"
                selected={to_string(@enquiry_form[:category].value) == "wrong_address"}
              >
                Wrong address
              </option>
              <option
                value="missing_item"
                selected={to_string(@enquiry_form[:category].value) == "missing_item"}
              >
                Missing item
              </option>
              <option
                value="general"
                selected={to_string(@enquiry_form[:category].value) == "general"}
              >
                General question
              </option>
            </select>
            <div
              :for={{msg, _opts} <- @enquiry_form[:category].errors}
              class="mt-1 text-sm text-red-600"
            >
              {msg}
            </div>
          </div>

          <div>
            <.input
              field={@enquiry_form[:message]}
              type="textarea"
              label="Message"
              rows="4"
              placeholder="Tell us what's going on..."
              class="w-full rounded-md border border-slate-300 px-3 py-2 text-slate-900"
            />
          </div>

          <button
            type="submit"
            phx-disable-with="Sending..."
            class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg disabled:opacity-60"
          >
            Submit Enquiry
          </button>
        </.form>
      </div>
    </div>
    """
  end
end
