#!/usr/bin/env python3
"""Delete one saved finger through fprintd, keeping the device claim alive."""
import sys

from gi.repository import Gio, GLib


def main():
    fingers = {
        f"{hand}-{finger}"
        for hand in ("left", "right")
        for finger in ("thumb", "index-finger", "middle-finger", "ring-finger", "little-finger")
    }
    if len(sys.argv) != 2 or sys.argv[1] not in fingers:
        raise ValueError("Specify one valid finger name")
    bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
    flags = Gio.DBusCallFlags.ALLOW_INTERACTIVE_AUTHORIZATION

    def call(path, interface, method, parameters=None):
        return bus.call_sync(
            "net.reactivated.Fprint", path, interface, method, parameters,
            None, flags, 120000, None,
        )

    path = call("/net/reactivated/Fprint/Manager", "net.reactivated.Fprint.Manager",
                "GetDefaultDevice").unpack()[0]
    interface = "net.reactivated.Fprint.Device"
    # Empty username means the caller's own account, as specified by fprintd.
    call(path, interface, "Claim", GLib.Variant("(s)", ("",)))
    try:
        call(path, interface, "DeleteEnrolledFinger", GLib.Variant("(s)", (sys.argv[1],)))
        print(f"Deleted saved fingerprint: {sys.argv[1]}")
    finally:
        call(path, interface, "Release")


if __name__ == "__main__":
    try:
        main()
    except (GLib.Error, ValueError) as error:
        print(f"Could not delete fingerprint: {error}", file=sys.stderr)
        sys.exit(1)
