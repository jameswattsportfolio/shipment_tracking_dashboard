defmodule ShipmentTrackingDashboardWeb.Api.ShipmentController do
  use ShipmentTrackingDashboardWeb, :controller

  alias ShipmentTrackingDashboard.Shipments

  action_fallback ShipmentTrackingDashboardWeb.FallbackController

  # GET /api/shipments/:tracking_number  (public)
  def show(conn, %{"tracking_number" => tracking_number}) do
    case Shipments.get_shipment_by_tracking_number(tracking_number) do
      nil -> {:error, :not_found}
      shipment -> render(conn, :show, shipment: shipment)
    end
  end

  # GET /api/staff/shipments?status=delayed  (staff)
  def index(conn, params) do
    shipments = Shipments.list_shipments(params)
    render(conn, :index, shipments: shipments)
  end

  # POST /api/staff/shipments
  def create(conn, %{"shipment" => shipment_params}) do
    with {:ok, shipment} <- Shipments.create_shipment(shipment_params) do
      conn
      |> put_status(:created)
      |> render(:show, shipment: shipment)
    end
  end

  # PATCH /api/staff/shipments/:id
  def update(conn, %{"id" => id, "shipment" => shipment_params}) do
    with shipment when not is_nil(shipment) <- Shipments.get_shipment(id),
         {:ok, shipment} <- Shipments.update_shipment(shipment, shipment_params) do
      render(conn, :show, shipment: shipment)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  # POST /api/staff/shipments/:id/events
  def add_event(conn, %{"id" => id, "event" => event_params}) do
    with shipment when not is_nil(shipment) <- Shipments.get_shipment(id),
         {:ok, event} <- Shipments.create_event(shipment, event_params) do
      conn
      |> put_status(:created)
      |> render(:event, event: event)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end
end
