# Build Something

Turn an idea into a real app with a link you can share, without knowing how to code.

You describe what you want. Claude sets up your computer, shows you a few designs to choose from, builds the app (a website, or an iPhone app you can try on your own phone), and puts it online for free on Cloudflare. You get back a link that works on any phone or computer.

## Install (one time)

You need [Claude Code](https://claude.com/claude-code) installed. Open it and type these two lines, one at a time:

```
/plugin marketplace add osroc-labs/build-something
/plugin install build-something@build-something
```

Then quit Claude Code and open it again.

## Use it

Type:

```
/build-something
```

and say what you want to make, e.g. *"a sign-up sheet for my pickup soccer games"* or *"a shared grocery list for my roommates"*.

Along the way you'll:

1. Answer a few questions about your idea.
2. Pick between a few designs Claude shows you.
3. Try each piece as it's built and say whether it works.
4. Log in to Cloudflare once in your browser (it's free; no credit card).

Building an iPhone app? Install the free **Expo Go** app from the App Store to try it on your phone. If you have a [Fleet](https://fleet.osroc.io) invite, Claude can also test it on iPhone simulators for you.

Run `/build-something` again any time to change an app, see all your apps, or start a new one. Your apps are saved in the `apps` folder in your home folder.
