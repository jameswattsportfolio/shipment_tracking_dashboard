alias ShipmentTrackingDashboard.{Accounts, Shipments, Enquiries}

# --- Demo staff account -----------------------------------------------
# Password login doesn't require confirmed_at, so register_user/1 alone
# is sufficient here — no separate confirmation step needed.
staff_email = "staff@demo.com"
staff_password = "demopassword123!"

unless Accounts.get_user_by_email(staff_email) do
  {:ok, staff} = Accounts.register_user(%{email: staff_email})

  {:ok, {_user, _expired_tokens}} =
    Accounts.update_user_password(staff, %{
      password: staff_password,
      password_confirmation: staff_password
    })
end

# --- Helper to create a shipment with a full event timeline ------------
create_shipment_with_events = fn shipment_attrs, events ->
  case Shipments.get_shipment_by_tracking_number(shipment_attrs["tracking_number"]) do
    nil ->
      {:ok, shipment} = Shipments.create_shipment(shipment_attrs)

      Enum.each(events, fn event_attrs ->
        {:ok, _event} = Shipments.create_event(shipment, event_attrs)
      end)

      shipment

    existing ->
      existing
  end
end

now = DateTime.utc_now() |> DateTime.truncate(:second)
days_ago = fn n -> DateTime.add(now, -n * 86_400, :second) end

# TRK-DEMO-001 — Normal shipment in transit, several events
create_shipment_with_events.(
  %{
    "tracking_number" => "TRK-DEMO-001",
    "status" => "collected",
    "current_location" => "Manchester Distribution Centre",
    "origin" => "Manchester, UK",
    "destination" => "Bristol, UK",
    "service_level" => "standard",
    "package_count" => 1,
    "total_weight" => Decimal.new("2.4"),
    "expected_delivery_date" => Date.add(Date.utc_today(), 2)
  },
  [
    %{
      "occurred_at" => days_ago.(3),
      "location" => "Manchester Depot",
      "status" => "created",
      "message" => "Shipment created and awaiting collection"
    },
    %{
      "occurred_at" => days_ago.(2),
      "location" => "Manchester Depot",
      "status" => "collected",
      "message" => "Collected from sender"
    },
    %{
      "occurred_at" => days_ago.(1),
      "location" => "Birmingham Sorting Hub",
      "status" => "collected",
      "message" => "Arrived at sorting hub, continuing to destination"
    }
  ]
)

# TRK-DEMO-002 — Delivered shipment, final delivered event
create_shipment_with_events.(
  %{
    "tracking_number" => "TRK-DEMO-002",
    "status" => "delivered",
    "current_location" => "Bristol, UK",
    "origin" => "Leeds, UK",
    "destination" => "Bristol, UK",
    "service_level" => "express",
    "package_count" => 2,
    "total_weight" => Decimal.new("5.1"),
    "expected_delivery_date" => Date.add(Date.utc_today(), -1),
    "actual_delivery_date" => Date.add(Date.utc_today(), -1)
  },
  [
    %{
      "occurred_at" => days_ago.(4),
      "location" => "Leeds Depot",
      "status" => "created",
      "message" => "Shipment created and awaiting collection"
    },
    %{
      "occurred_at" => days_ago.(3),
      "location" => "Leeds Depot",
      "status" => "collected",
      "message" => "Collected from sender"
    },
    %{
      "occurred_at" => days_ago.(1),
      "location" => "Bristol Depot",
      "status" => "out_for_delivery",
      "message" => "Out for delivery"
    },
    %{
      "occurred_at" => days_ago.(1),
      "location" => "Bristol, UK",
      "status" => "delivered",
      "message" => "Delivered — signed for by recipient"
    }
  ]
)

# TRK-DEMO-003 — Delayed shipment, updated ETA + explanatory event
create_shipment_with_events.(
  %{
    "tracking_number" => "TRK-DEMO-003",
    "status" => "delayed",
    "current_location" => "Birmingham Sorting Hub",
    "origin" => "Glasgow, UK",
    "destination" => "London, UK",
    "service_level" => "standard",
    "package_count" => 1,
    "total_weight" => Decimal.new("1.8"),
    "expected_delivery_date" => Date.add(Date.utc_today(), 4)
  },
  [
    %{
      "occurred_at" => days_ago.(5),
      "location" => "Glasgow Depot",
      "status" => "created",
      "message" => "Shipment created and awaiting collection"
    },
    %{
      "occurred_at" => days_ago.(4),
      "location" => "Glasgow Depot",
      "status" => "collected",
      "message" => "Collected from sender"
    },
    %{
      "occurred_at" => days_ago.(1),
      "location" => "Birmingham Sorting Hub",
      "status" => "delayed",
      "message" =>
        "Delay due to high volume at sorting hub — new estimated delivery date has been set"
    }
  ]
)

# TRK-DEMO-004 — Exception shipment, clear issue message
create_shipment_with_events.(
  %{
    "tracking_number" => "TRK-DEMO-004",
    "status" => "cancelled",
    "current_location" => "London Depot",
    "origin" => "Cardiff, UK",
    "destination" => "London, UK",
    "service_level" => "standard",
    "package_count" => 1,
    "total_weight" => Decimal.new("3.2"),
    "expected_delivery_date" => Date.add(Date.utc_today(), 1)
  },
  [
    %{
      "occurred_at" => days_ago.(2),
      "location" => "Cardiff Depot",
      "status" => "created",
      "message" => "Shipment created and awaiting collection"
    },
    %{
      "occurred_at" => days_ago.(1),
      "location" => "Cardiff Depot",
      "status" => "collected",
      "message" => "Collected from sender"
    },
    %{
      "occurred_at" => now,
      "location" => "London Depot",
      "status" => "cancelled",
      "message" => "Delivery address could not be verified — action required, contact support"
    }
  ]
)

# TRK-DEMO-005 — New / collected shipment, only 1–2 events
create_shipment_with_events.(
  %{
    "tracking_number" => "TRK-DEMO-005",
    "status" => "collected",
    "current_location" => "Edinburgh Depot",
    "origin" => "Edinburgh, UK",
    "destination" => "Newcastle, UK",
    "service_level" => "standard",
    "package_count" => 1,
    "total_weight" => Decimal.new("0.9"),
    "expected_delivery_date" => Date.add(Date.utc_today(), 5)
  },
  [
    %{
      "occurred_at" => days_ago.(1),
      "location" => "Edinburgh Depot",
      "status" => "created",
      "message" => "Shipment created and awaiting collection"
    },
    %{
      "occurred_at" => now,
      "location" => "Edinburgh Depot",
      "status" => "collected",
      "message" => "Collected from sender"
    }
  ]
)

if Enquiries.list_enquiries() == [] do
  # --- A few seeded enquiries, spanning open/resolved --------------------
  Enquiries.create_enquiry(%{
    "tracking_number" => "TRK-DEMO-003",
    "category" => "general",
    "message" => "Why has my shipment been delayed? I was expecting it tomorrow."
  })

  {:ok, resolved} =
    Enquiries.create_enquiry(%{
      "tracking_number" => "TRK-DEMO-002",
      "category" => "general",
      "message" => "Can you confirm this was delivered? I didn't get a notification."
    })

  Enquiries.update_enquiry_status(resolved, %{"status" => "resolved"})
end

IO.puts("Seed data created: 5 demo shipments (TRK-DEMO-001 to 005), 2 demo enquiries")
