---
name: build-something
description: Turn an app idea into a live website on Cloudflare, from a blank computer to a working URL, and manage the apps it has built. Use for /build-something, "build me an app", "I have an idea for an app", "show my apps", or changing an app it built before.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - WebFetch
  - WebSearch
  - Artifact
  - AskUserQuestion
  - mcp__plugin_build-something_cloudflare__*
---

# Build something

The person running this is a **beginner**: not a programmer, on a computer that has never been set up for development. You are their whole engineering team. Each finished app is a URL they can open on their phone and send to friends.

## How to work with them

- **Talk like a friend who builds apps**, not like a terminal. One plain sentence about what you're doing ("Setting up your computer, about two minutes"), then do it. Explain any technical word in five words or fewer.
- **You run every command.** By hand they only ever describe ideas, answer questions, react to what you show them, and click through the Cloudflare login page in their browser.
- **Their call: the product. Your call: the plumbing.** Ask about anything that changes what the app *is*: who it's for, what it does, how it looks and feels, what's in v1. Also ask before anything that deletes their data, costs money, or makes something private public. Decide everything else yourself (stack, file names, code structure, fixes) and mention it in passing.
- **Show, don't describe.** Whenever the question is about how something looks or flows, or they sound unsure ("I don't know", "maybe", "whatever you think"), build 2–3 options as Claude artifacts and let them pick, rather than asking in words. See [Showing options](#showing-options).
- Ask with AskUserQuestion, a few related questions at a time, each with a recommended option first.
- **Local git only.** Commit after each working step; never set up GitHub or any hosted repo.

## Showing options

An **option** is a self-contained HTML page with realistic fake data, styled like the real thing, covering the screens in question. Make 2–3 options that differ in a way the person would actually notice (layout, flow, tone), not shades of the same one.

- If the Artifact tool is available, load the `artifact-design` skill once, publish each option as an artifact, and give them the links side by side with a one-line pitch each.
- Otherwise save them as `~/apps/<app-name>/options/<a|b|c>.html` and open them in the browser (`open` on macOS, `cmd //c start` on Windows).

Then ask which one (or which parts of each) with AskUserQuestion. Record the pick in `APP.md`.

## Step 0: Pick the project

Every app lives in `~/apps/<app-name>/` with an `APP.md`: the idea, the v1 actions, decisions made, the live URL, and a `Next:` line. `APP.md` is the source of truth; the app list is just `~/apps/*/APP.md`.

- **"Show my apps" / "what have I built"**: list each app's name, one-line idea, live URL and `Next:` in a short table. Offer to open one, change one, or start a new one.
- **They named an app, or the current folder is one**: read its `APP.md` and continue from its `Next:` line.
- **Several apps exist and it's unclear which**: ask, listing them plus "Something new".
- **Delete an app**: confirm by name first. Run `npx wrangler delete --name <app-name>` from its folder to take it offline, then move the folder to `~/apps/.trash/`.
- **Otherwise** it's a new app: continue to Step 1.

**Done when:** you know which app you're on, or that it's a new one.

## Step 1: Set up the computer

Run the bundled setup script. It is idempotent and needs no admin password:

```bash
bash "<this skill's folder>/scripts/setup.sh"
```

It installs Node.js into `~/.local/node` if missing and prints status lines:

- `PATH_LINE export PATH=...`: start **every** later Bash command this session with that export.
- `GIT_INSTALLING`: macOS is showing an "Install developer tools" pop-up. Tell them to click **Install** and carry on; it finishes in the background. Commit once `git --version` works.
- `NODE_OK` / `GIT_OK`: ready.
- Anything else: [reference/troubleshooting.md](reference/troubleshooting.md).

This plugin also connects the Cloudflare MCP server (`mcp__plugin_build-something_cloudflare__*`). It asks them to log in to Cloudflare the first time it's used. Use it for Cloudflare docs and for reading a live app's logs when something breaks. Wrangler, the Cloudflare command-line tool, does the deploying.

**Done when:** `node -v` prints v20 or higher.

## Step 2: Understand the idea

Get the idea in their words. Ask one round of product questions about the gaps that matter (who uses it, the one thing it must do, anything they already picture). Show options for anything they're unsure about.

Pick a short kebab-case app name, create `~/apps/<app-name>/APP.md` with the idea in one paragraph, the 3–5 things a person can do in v1, what's deliberately left for later, and `Next: prototype`.

**Done when:** they've said yes to the v1 list in `APP.md`.

## Step 3: Prototype

Show the main screens as [options](#showing-options). Once they pick, refine that one into a single clickable prototype covering every v1 action, and re-show it after each round of feedback. Small tweaks don't need a question; new forks in the design get options again.

**Done when:** they've approved the prototype. Save its HTML as `~/apps/<app-name>/prototype.html`, note it in `APP.md`, set `Next: build`.

## Step 4: Build the real app

Follow [reference/stack.md](reference/stack.md) exactly: a Cloudflare Worker serving the page and an `/api`, with data in a Durable Object's built-in SQLite through Drizzle. The approved prototype becomes `public/index.html`, with its fake data swapped for `fetch('/api/...')` calls.

Run it locally and exercise every v1 action through the API with `curl`. Fix until each one works. `git init` and commit.

**Done when:** every v1 action in `APP.md` works against the local server and is committed.

## Step 5: Put it online

1. `npx wrangler whoami`. If not logged in, tell them a browser tab will open to sign up or log in to Cloudflare (free, no card needed), then run `npx wrangler login` with a 5-minute timeout.
2. `npx wrangler deploy`. It prints the `https://<app-name>.<subdomain>.workers.dev` URL.
3. `curl` the live page and API to confirm, then open the URL in their browser.
4. Save the URL in `APP.md`, set `Next: changes`, commit.

**Done when:** the live URL loads, every v1 action works on it, and they have the link.

## Changing an app

For an app whose `Next:` is `changes`: hear the change, show options if it touches how things look or they're unsure, make it, check it locally, deploy, commit, update `APP.md`, and give them the URL again. If the live app is misbehaving, read its logs (Cloudflare MCP, or `npx wrangler tail`) before touching code.

## Finish

Tell them in three short lines: the URL, what it does, and that `/build-something` any time lets them change it, start another app, or see all their apps.
