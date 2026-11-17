# Podatos — Claude 5-hour window starter

Starts your Claude 5-hour usage window automatically whenever it's sitting
unused, with a ping of a few dozen tokens (Haiku, no tools, 1-character
message). Plus a phone notification + home-screen buttons for your S24+.

## 1. Automation (GitHub Actions — no phone needed)

1. On any computer with Claude Code: `claude setup-token` → copy the `sk-ant-oat01-…` token.
2. Repo → Settings → Secrets and variables → Actions → New secret
   `CLAUDE_CODE_OAUTH_TOKEN` = that token.
3. Merge this branch into `main` (scheduled workflows only run from the default branch).

Every 30 min the workflow checks your 5h window and pings only if it's idle.
Manual run: Actions tab → "Start Claude 5h window" → Run workflow (works from the GitHub app).

Notes: GitHub cron can lag 5–15 min. GitHub pauses schedules after 60 days with
no repo commits (it emails you; one click re-enables). On a private repo each run
bills ~1 Actions minute (~1,440/mo of the free 2,000).

## 2. Phone (Samsung S24+)

Install from **F-Droid** (not Play Store): Termux, Termux:API, Termux:Widget.
Create a GitHub fine-grained token: this repo only, *Actions: Read and write*.

In Termux:
```sh
pkg install -y git
git clone https://github.com/uzuriella/podatos && cd podatos/android
bash setup.sh        # asks for the two tokens, stored in ~/.config/claude5h/env (chmod 600)
```
(For a private repo, git asks for a password — paste the GitHub token.)

Then long-press home screen → Widgets → Termux:Widget. You get:
- **Claude status** — toast: 🟢 UNUSED / ⏳ running, % used, reset time
- **Claude start** — starts a window now

A pinned notification refreshes every 15 min with **Start** / **Refresh** buttons,
so you can see at a glance whether the window is untouched.
Samsung: Settings → Apps → Termux/Termux:API → Battery → *Unrestricted*, or One UI
will kill the background refresh.
