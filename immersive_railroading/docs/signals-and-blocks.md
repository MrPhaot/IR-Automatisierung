# Signals And Blocks

V1 does not enforce block reservations in production code yet.

That separation is intentional:
- `train_controller.lua` owns local motion control only
- future `signal_reservation.lua` should own block claims and releases
- future `junction_controller.lua` should own switch alignment and locking
- `station_dispatch.lua` now owns schedule waits, detector checks, and station-side redstone handoff

Still intentionally outside V1:
- no block reservation coupling
- no graph/junction implementation
- no redstone input waits

Reference reservation shape kept stable for later sessions:

```lua
BLOCKS = {
  main_01 = {owner = nil},
  main_02 = {owner = nil},
}

ROUTES = {
  northbound_main = {
    blocks = {"main_01", "main_02"},
    switches = {J1 = "main"},
  }
}
```

The preview test in `tests/previews/reservation_preview.lua` exists to keep this future contract concrete without prematurely coupling it to the V1 controller.
