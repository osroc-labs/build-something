# Troubleshooting

Fix it yourself where you can; the person only needs to know if they have to click something.

## Setup script

- **`UNSUPPORTED_OS` / `UNSUPPORTED_ARCH`**: install Node.js 20+ by hand. Windows: `winget install --id OpenJS.NodeJS.LTS -e` (may show an admin prompt they need to approve). Linux: download from nodejs.org/dist into `~/.local/node` the way the script does.
- **`NODE_DOWNLOAD_NOT_FOUND` / `NODE_CHECKSUM_MISMATCH` / curl errors**: usually a flaky network or a proxy. Retry once; then check `curl -I https://nodejs.org`.
- **`GIT_MISSING`**: Windows: `winget install --id Git.Git -e`. Linux: their package manager (needs their password; ask). Until then, build and deploy without commits.
- **`node` not found later in the session**: you forgot the `PATH_LINE` export on that command.

## Cloudflare

- **`wrangler login` times out**: they didn't finish in the browser. Ask if the tab opened; rerun. If no tab opens, the command prints a URL: give it to them to open.
- **"You need to register a workers.dev subdomain"**: have them open https://dash.cloudflare.com, go to **Workers & Pages** once (this creates the subdomain), then deploy again.
- **"Please verify your email"**: Cloudflare sent them a verification email at sign-up. They click it, then deploy again.
- **Name already taken / deploy refuses the name**: change `name` in `wrangler.jsonc` and in `APP.md`.
- **Durable Object migration errors on deploy**: you edited or removed an existing entry in `migrations`. Restore it exactly; only append new tags.
- **Live site shows an error**: `npx wrangler tail` (or the Cloudflare MCP's observability tools), reproduce it, read the stack trace, fix, redeploy.

## Drizzle

- **"no such table" locally**: you changed the schema but didn't run `npm run db`, or `wrangler dev` is still running the old code. Run it and restart.
- **Import of `.sql` fails**: the `rules` block for `**/*.sql` is missing from `wrangler.jsonc`.
- **Messed-up local data**: delete `.wrangler/state` to start the local database fresh. This never touches the live app's data.
