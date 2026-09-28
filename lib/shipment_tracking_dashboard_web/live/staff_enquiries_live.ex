defmodule ShipmentTrackingDashboardWeb.StaffEnquiriesLive do
  use ShipmentTrackingDashboardWeb, :live_view

  alias ShipmentTrackingDashboard.Enquiries

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    filters = %{"status" => params["status"] || ""}

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> assign(:enquiries, Enquiries.list_enquiries(filters))}
  end

  @impl true
  def handle_event("filter", params, socket) do
    query = %{status: params["status"] || ""}
    {:noreply, push_patch(socket, to: ~p"/staff/enquiries?#{query}")}
  end

  @impl true
  def handle_event("resolve", %{"id" => id}, socket) do
    enquiry = Enquiries.get_enquiry(id)

    case Enquiries.update_enquiry_status(enquiry, %{"status" => "resolved"}) do
      {:ok, _enquiry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Enquiry marked as resolved")
         |> assign(:enquiries, Enquiries.list_enquiries(socket.assigns.filters))}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not update enquiry")}
    end
  end

  @impl true
  def handle_event("reopen", %{"id" => id}, socket) do
    enquiry = Enquiries.get_enquiry(id)

    case Enquiries.update_enquiry_status(enquiry, %{"status" => "open"}) do
      {:ok, _enquiry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Enquiry reopened")
         |> assign(:enquiries, Enquiries.list_enquiries(socket.assigns.filters))}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not update enquiry")}
    end
  end

  defp category_label(category),
    do: category |> to_string() |> String.replace("_", " ") |> String.capitalize()

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-5xl mx-auto">
      <div class="mb-8">
        <h1 class="text-4xl font-bold text-slate-800">Customer Enquiries</h1>
        
        <p class="mt-2 text-slate-600">Review and resolve enquiries submitted against shipments.</p>
      </div>
      
      <form phx-change="filter" class="mb-6">
        <label for="status" class="block text-sm font-medium text-slate-700 mb-1">
          Status
        </label>
        
        <select
          id="status"
          name="status"
          class="rounded-md border border-slate-300 px-3 py-2 text-sm bg-slate-100 text-slate-900"
        >
          <option value="" selected={@filters["status"] == ""}>All enquiries</option>
          
          <option value="open" selected={@filters["status"] == "open"}>Open</option>
          
          <option value="resolved" selected={@filters["status"] == "resolved"}>Resolved</option>
        </select>
      </form>
      
      <div
        :if={Enum.empty?(@enquiries)}
        class="bg-white rounded-lg shadow p-8 text-center text-slate-500"
      >
        No enquiries found.
      </div>
      
      <div class="space-y-4">
        <div :for={enquiry <- @enquiries} class="bg-white rounded-lg shadow p-6">
          <div class="flex justify-between items-start mb-3">
            <div>
              <p class="font-semibold text-slate-800">{enquiry.tracking_number}</p>
              
              <p class="text-sm text-slate-500">
                {category_label(enquiry.category)} · {enquiry.inserted_at}
              </p>
            </div>
            
            <span class={[
              "px-3 py-1 text-xs font-semibold rounded-full",
              enquiry.status == :open && "bg-amber-100 text-amber-800",
              enquiry.status == :resolved && "bg-green-100 text-green-700"
            ]}>
              {enquiry.status |> to_string() |> String.capitalize()}
            </span>
          </div>
          
          <p class="text-slate-700 mb-4">{enquiry.message}</p>
          
          <div class="flex justify-end">
            <button
              :if={enquiry.status == :open}
              phx-click="resolve"
              phx-value-id={enquiry.id}
              class="px-3 py-1 bg-green-600 text-white rounded hover:bg-green-700 text-sm"
            >
              Mark Resolved
            </button>
            
            <button
              :if={enquiry.status == :resolved}
              phx-click="reopen"
              phx-value-id={enquiry.id}
              class="px-3 py-1 border border-slate-300 text-slate-700 rounded hover:bg-slate-100 text-sm"
            >
              Reopen
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
