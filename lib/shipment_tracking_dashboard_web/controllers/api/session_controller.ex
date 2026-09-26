defmodule ShipmentTrackingDashboardWeb.Api.SessionController do
  use ShipmentTrackingDashboardWeb, :controller

  alias ShipmentTrackingDashboard.Accounts
  alias ShipmentTrackingDashboardWeb.UserAuth

  # email + password login
  def create(conn, %{"user" => %{"email" => email, "password" => password} = user_params}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> UserAuth.log_in_user_api(user, user_params)
      |> put_status(:ok)
      |> json(%{status: "ok", email: user.email})
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "invalid email or password"})
    end
  end

  def delete(conn, _params) do
    conn
    |> UserAuth.log_out_user_api()
    |> json(%{status: "ok"})
  end
end
