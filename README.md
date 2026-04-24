# US Stock Tracker — Daily Briefs

Automated public mirror of daily US equity briefs and the HiveMind graph viewer, produced by the private [US-Stock-Tracker](https://github.com/nimitmehra/us-stock-tracker) pipeline.

## Live viewer

**[nimitmehra.github.io/us-stock-tracker-briefs/viewer.html](https://nimitmehra.github.io/us-stock-tracker-briefs/viewer.html)**

Interactive Cytoscape graph of ~40 tracked tickers and their macro / sector / commodity edges. Refreshes every evening after the pipeline runs.

## What this is

Each trading day, a Claude Code pipeline fires at 5 PM ET (one hour after US market close):

1. **Gathers intel** — news, market action, SEC filings (three parallel sub-agents).
2. **Updates a knowledge graph** — 42 nodes (stocks + macros), 98 edges; signals cascade, triggers fire.
3. **Writes a brief** — in the voice of *The Economist's* "World in Brief."
4. **Verifies the brief** — six adversarial checks before publish.
5. **Dispatches deep research** — async, when a stock crosses a signal threshold (10/day cap).

Only briefs and the viewer are mirrored here. The code, graph state, and ~60 deep research reports stay private.

## Structure

```
briefs/YYYY-MM-DD.md    Daily brief — TL;DR, What Happened, Trigger Watch,
                        Cascade Watch, Graph Signal
viewer.html             Interactive HiveMind graph (Cytoscape)
```

## Reading the briefs

Each brief is ~400-800 words, designed to be read in 3 minutes:

- **TL;DR** — the one thing that matters today.
- **What Happened** — 4-6 paragraphs of connected narrative, not bullets.
- **Action Items** — triggers fired, DRs queued, position-sizing moves.
- **Trigger Watch** — every Tier 1 stock with a trigger at `watching` or `elevated`.
- **Cascade Watch** — macro edges that moved today, with the fan-out they imply.
- **Graph Signal** — the pattern across days only the pipeline can see.

## License

Informational only — not investment advice, no warranty, use at your own risk.
