# iPhone apps: Expo

An iPhone app is **one Expo codebase** that runs on iPhone, Android and the web, talking to the same Cloudflare Worker + Durable Object + Drizzle backend as a website ([stack.md](stack.md)). The web version deploys to Cloudflare too, so there's still a link to share on day one. The App Store comes later and costs money (below).

Expo handles the native plumbing: no Xcode project to edit, no Android Studio. They preview on their own iPhone with the free **Expo Go** app.

## Expo has changed: read the docs, not your memory

Expo ships breaking changes every SDK. Before writing code that touches an Expo or React Native API:

1. Read the `expo` major version in `package.json`.
2. Fetch `https://docs.expo.dev/versions/v<major>.0.0/` for that API, or start from `https://docs.expo.dev/llms.txt` (an index with corrections to common LLM mistakes).

Rules that hold across SDKs:

- **Add packages with `npx expo install <pkg>`**, never `npm i`: it picks versions that match the SDK.
- **Navigation is Expo Router**: every file in `app/` (or `src/app/`) is a screen; `_layout.tsx` defines navigators. Components and helpers live outside it.
- **Never create or edit `ios/` or `android/`.** Native settings go in `app.json` and config plugins.
- **Stay inside Expo Go** for v1: use only Expo SDK modules and pure-JS libraries. A library with its own native code needs a development build (Apple developer account, or a Mac with Xcode); ask before going there.
- Before calling anything done: `npx tsc --noEmit`, `npx expo lint`, `npx expo-doctor`.

## Scaffold

```bash
cd ~/apps
npx create-expo-app@latest <app-name> --yes
cd <app-name>
npm i hono drizzle-orm
npm i -D wrangler drizzle-kit
mkdir -p worker/db
```

Then add the backend from [stack.md](stack.md), with these differences:

- The Worker lives in `worker/` (`worker/index.ts`, `worker/db/schema.ts`), with its own `worker/tsconfig.json` (stack.md's, with `"types": ["./worker-configuration.d.ts"]` and `"include": ["."]`). Add `"worker"` to `exclude` in the root `tsconfig.json` so Expo's typecheck ignores it.
- `drizzle.config.ts`: `schema: "./worker/db/schema.ts"`, `out: "./worker/drizzle"`; the Worker imports `./drizzle/migrations`.
- `wrangler.jsonc`: `"main": "worker/index.ts"` and `"assets": { "directory": "./dist", "not_found_handling": "single-page-application", "run_worker_first": ["/api/*"] }` (`dist/` is the web build).
- `package.json` scripts: `"types": "wrangler types worker/worker-configuration.d.ts"`, `"db": "drizzle-kit generate"`, `"deploy": "expo export -p web && wrangler deploy"`.
- `.gitignore` gains `.wrangler/`, `dist/`.

Replace the template's example screens with the approved prototype's screens.

## Where the app finds its API

- On the web build, the page and API share an origin: call `/api/...`.
- On a phone, `localhost` is the phone itself. Deploy the Worker once early (`npx wrangler deploy` with an empty `dist/` is fine) and set `EXPO_PUBLIC_API_URL=https://<app-name>.<subdomain>.workers.dev` in `.env`. The app calls `` `${process.env.EXPO_PUBLIC_API_URL ?? ""}/api/...` ``.
- That means previews use the live database. Fine for a v1 with only them on it; once other people use it, ask before any change that could break or wipe their data.
- **Phones lag the server.** Installed apps run old code for a while, so API changes only *add* fields and endpoints; never rename or remove one an installed app uses.

## Preview on their iPhone

1. They install **Expo Go** from the App Store (free), and their phone is on the same Wi-Fi as the computer.
2. Start the dev server in the background under a pretend terminal, or Expo won't print its URL: `script -q /dev/null npx expo start --lan > .expo-dev.log 2>&1` (macOS; on Linux `script -qc "npx expo start --lan" /dev/null`). Pull the URL out with `grep -ao 'exp://[0-9a-z.:-]*' .expo-dev.log | head -1`.
3. They can't scan a QR code from your terminal output. Write `~/apps/<app-name>/preview.html` with a big QR code for that URL (a QR library from cdnjs) and the URL as text, and open it in their browser. They point the iPhone camera at it and tap the banner.
4. Different networks or a fussy Wi-Fi: `npm i -D @expo/ngrok` once, then the same command with `--tunnel`, and use the `exp://…exp.direct` URL it prints.
5. "Incompatible with this version of Expo Go": they update Expo Go from the App Store.

The first `expo start` also writes `expo-env.d.ts`; until then `npx tsc --noEmit` complains about the template's CSS imports.

Code changes reload on the phone by themselves. Before handing over anything new, smoke-test it on a simulator ([simulators.md](simulators.md)) when one is available.

## Put it online

`npm run deploy` publishes the web version and the API: the link to share. Phones in Expo Go keep working from the dev server while it runs.

## The App Store (later, ask first)

Getting it onto other people's iPhones as a real app needs an Apple Developer account ($99/year) and an Expo account, then `npx eas-cli@latest build -p ios --profile production --auto-submit` (cloud build: no Xcode) and TestFlight. Their Apple sign-in and payment are theirs to do. Bring it up when v1 is working and they want friends to install it; until then the web link is the shareable version.
