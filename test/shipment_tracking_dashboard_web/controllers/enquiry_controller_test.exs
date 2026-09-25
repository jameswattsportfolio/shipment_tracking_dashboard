defmodule ShipmentTrackingDashboardWeb.Api.EnquiryControllerTest do
  use ShipmentTrackingDashboardWeb.ConnCase, async: true

  import ShipmentTrackingDashboard.EnquiriesFixtures
  import ShipmentTrackingDashboard.AccountsFixtures

  describe "POST /api/enquiries (public)" do
    test "creates an enquiry with valid params", %{conn: conn} do
      conn =
        post(conn, ~p"/api/enquiries", %{
          "enquiry" => %{
            "tracking_number" => "TRK-DEMO-001",
            "category" => "general",
            "message" => "Can you confirm the delivery window?"
          }
        })

      assert %{"data" => data} = json_response(conn, 201)
      assert data["tracking_number"] == "TRK-DEMO-001"
      assert data["status"] == "open"
    end

    test "rejects an enquiry missing required fields", %{conn: conn} do
      conn =
        post(conn, ~p"/api/enquiries", %{
          "enquiry" => %{"tracking_number" => "", "category" => "general", "message" => ""}
        })

      assert %{"errors" => errors} = json_response(conn, 422)
      assert errors["tracking_number"]
      assert errors["message"]
    end

    test "does not require real customer identity fields", %{conn: conn} do
      # Brief: "do not require real personal information ... tracking number,
      # enquiry category and message are sufficient"
      conn =
        post(conn, ~p"/api/enquiries", %{
          "enquiry" => %{
            "tracking_number" => "TRK-DEMO-002",
            "category" => "damaged_item",
            "message" => "The package arrived damaged."
          }
        })

      assert %{"data" => _data} = json_response(conn, 201)
    end
  end

  describe "GET /api/staff/enquiries (protected)" do
    test "rejects an unauthenticated request", %{conn: conn} do
      conn = get(conn, ~p"/api/staff/enquiries")

      assert %{"error" => "unauthenticated"} = json_response(conn, 401)
    end

    test "returns enquiries for an authenticated staff user", %{conn: conn} do
      user = user_fixture()
      enquiry_fixture(%{"tracking_number" => "TRK-DEMO-003"})

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/api/staff/enquiries")

      assert %{"data" => data} = json_response(conn, 200)
      assert Enum.any?(data, &(&1["tracking_number"] == "TRK-DEMO-003"))
    end

    test "filters by status", %{conn: conn} do
      user = user_fixture()
      open = enquiry_fixture(%{"tracking_number" => "TRK-DEMO-004"})
      resolved = enquiry_fixture(%{"tracking_number" => "TRK-DEMO-005"})

      {:ok, _} =
        ShipmentTrackingDashboard.Enquiries.update_enquiry_status(resolved, %{
          "status" => "resolved"
        })

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/api/staff/enquiries?status=open")

      assert %{"data" => data} = json_response(conn, 200)
      tracking_numbers = Enum.map(data, & &1["tracking_number"])

      assert open.tracking_number in tracking_numbers
      refute resolved.tracking_number in tracking_numbers
    end
  end

  describe "PATCH /api/staff/enquiries/:id (protected)" do
    test "rejects an unauthenticated request", %{conn: conn} do
      enquiry = enquiry_fixture()

      conn =
        patch(conn, ~p"/api/staff/enquiries/#{enquiry.id}", %{
          "enquiry" => %{"status" => "resolved"}
        })

      assert %{"error" => "unauthenticated"} = json_response(conn, 401)
    end

    test "allows staff to mark an enquiry resolved", %{conn: conn} do
      user = user_fixture()
      enquiry = enquiry_fixture()

      conn =
        conn
        |> log_in_user(user)
        |> patch(~p"/api/staff/enquiries/#{enquiry.id}", %{"enquiry" => %{"status" => "resolved"}})

      assert %{"data" => data} = json_response(conn, 200)
      assert data["status"] == "resolved"
    end

    test "returns 404 for an unknown enquiry id", %{conn: conn} do
      user = user_fixture()
      fake_id = Ecto.UUID.generate()

      conn =
        conn
        |> log_in_user(user)
        |> patch(~p"/api/staff/enquiries/#{fake_id}", %{"enquiry" => %{"status" => "resolved"}})

      assert %{"error" => _} = json_response(conn, 404)
    end

    test "does not let staff rewrite the original message via this endpoint", %{conn: conn} do
      user = user_fixture()
      enquiry = enquiry_fixture(%{"message" => "original message"})

      conn =
        conn
        |> log_in_user(user)
        |> patch(~p"/api/staff/enquiries/#{enquiry.id}", %{
          "enquiry" => %{"status" => "resolved", "message" => "tampered message"}
        })

      assert %{"data" => data} = json_response(conn, 200)
      assert data["message"] == "original message"
    end
  end
end
