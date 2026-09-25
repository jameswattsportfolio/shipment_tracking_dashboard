defmodule ShipmentTrackingDashboardWeb.EnquiryController do
  use ShipmentTrackingDashboardWeb, :controller

  alias ShipmentTrackingDashboard.Enquiries

  # action_fallback ShipmentTrackingDashboardWeb.Api.FallbackController

  # POST /api/enquiries  (public)
  def create(conn, %{"enquiry" => enquiry_params}) do
    with {:ok, enquiry} <- Enquiries.create_enquiry(enquiry_params) do
      conn
      |> put_status(:created)
      |> render(:show, enquiry: enquiry)
    end
  end

  # GET /api/staff/enquiries?status=open  (staff)
  def index(conn, params) do
    enquiries = Enquiries.list_enquiries(params)
    render(conn, :index, enquiries: enquiries)
  end

  # PATCH /api/staff/enquiries/:id  (staff)
  def update(conn, %{"id" => id, "enquiry" => enquiry_params}) do
    with enquiry when not is_nil(enquiry) <- Enquiries.get_enquiry(id),
         {:ok, enquiry} <- Enquiries.update_enquiry_status(enquiry, enquiry_params) do
      render(conn, :show, enquiry: enquiry)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end
end
