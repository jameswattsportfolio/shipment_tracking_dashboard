defmodule ShipmentTrackingDashboardWeb.Router do
  use ShipmentTrackingDashboardWeb, :router

  import ShipmentTrackingDashboardWeb.UserAuth
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ShipmentTrackingDashboardWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_current_scope_for_user
  end

  pipeline :api_authenticated do
    plug :require_authenticated_api_user
  end

  scope "/api", ShipmentTrackingDashboardWeb.Api do
    pipe_through :api

    post "/auth/login", SessionController, :create
    delete "/auth/logout", SessionController, :delete

    get "/shipments/:tracking_number", ShipmentController, :show
    post "/enquiries", EnquiryController, :create
  end

  scope "/api/staff", ShipmentTrackingDashboardWeb.Api do
    pipe_through [:api, :api_authenticated]

    get "/shipments", ShipmentController, :index
    post "/shipments", ShipmentController, :create
    patch "/shipments/:id", ShipmentController, :update
    post "/shipments/:id/events", ShipmentController, :add_event

    get "/enquiries", EnquiryController, :index
    patch "/enquiries/:id", EnquiryController, :update
  end

  scope "/", ShipmentTrackingDashboardWeb do
    pipe_through :browser

    live_session :default,
      layout: {ShipmentTrackingDashboardWeb.Layouts, :app} do
      get "/", PageController, :home
      live "/tracking", TrackingLive, :index
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:shipment_tracking_dashboard, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ShipmentTrackingDashboardWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ShipmentTrackingDashboardWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ShipmentTrackingDashboardWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

      live "/staff/dashboard", StaffDashboardLive
      live "/staff/shipments/new", ShipmentFormLive, :new
      live "/staff/shipments/:id/edit", ShipmentFormLive, :edit
      live "/staff/enquiries", StaffEnquiriesLive
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", ShipmentTrackingDashboardWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{ShipmentTrackingDashboardWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
