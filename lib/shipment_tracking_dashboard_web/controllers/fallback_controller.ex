defmodule ShipmentTrackingDashboardWeb.FallbackController do
  use ShipmentTrackingDashboardWeb, :controller

  alias Ecto.Changeset

  # Validation errors (422)
  def call(conn, {:error, %Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ShipmentTrackingDashboardWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # Resource not found (404)
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{
      error: "not found"
    })
  end

  # Authentication failure (401)
  def call(conn, {:error, :unauthenticated}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      error: "unauthenticated"
    })
  end

  # Catch-all (500)
  def call(conn, {:error, reason}) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{
      error: "internal_server_error",
      reason: inspect(reason)
    })
  end
end
