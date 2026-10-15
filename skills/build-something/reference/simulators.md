# iPhone simulators

A simulator is a pretend iPhone on a computer. Use one to **smoke-test** (walk the change yourself and look at a screenshot) before their real phone is the first place it runs. Their iPhone with Expo Go stays the final check: a simulator can't show haptics, real speed, or the camera.

Pick the first route that's available.

## 1. Fleet berths (no Xcode needed)

Fleet lends simulators running on Macs in a Fleet (osroc's tool), driven entirely by Claude. Nothing installs on their computer except the plugin.

**Set up once.** It needs a Fleet account; the person who shared this skill can send them an invite link.

1. They open the invite link (or sign in at https://fleet.osroc.io/app with Google).
2. Install the plugin (you run this):
   ```bash
   claude plugin marketplace add osroc-labs/fleet-plugin && claude plugin install fleet@osroc
   ```
3. They type `/fleet:login` in Claude Code, check the code matches in the browser tab that opens, and tap **Link Claude Code**. Plugins installed mid-session may need `/reload-plugins` (or a restart) first.

**Use.** Load the `fleet:berths` skill and follow it. In short: `fleet_status` → `voyage_start` → `lease` (`target: "iphone"`) → `boot` → `open_url` with the dev server's `exp://…` URL → `screenshot` and look → `tap` / `type_text` through the test steps → **`release`** and `voyage_close`, every time, even after a failure.

The berth can't reach this computer's `localhost` or LAN address: start Expo with `--tunnel` and open that `exp://…exp.direct` URL, or `fleet expose 8081` if the `fleet` CLI is installed.

## 2. Xcode's simulator on their Mac

Only if Xcode is already installed (`xcode-select -p` prints a path inside `Xcode.app`): `npx expo start --ios` boots a simulator and installs Expo Go on it. Screenshot with `xcrun simctl io booted screenshot <scratch>/shot.png` and look at it.

Installing Xcode from scratch is a 10+ GB App Store download that needs their Apple ID: ask first, and prefer Fleet.

## 3. Neither

Skip the simulator: check the web version in a browser (`npx expo start --web`), then hand it to their phone with careful test steps. Say plainly that you couldn't try it on an iPhone first.

## Shut down what you start

Before you finish: release every Fleet lease, stop Expo and `wrangler dev`, and shut down local simulators (`xcrun simctl shutdown all`).
