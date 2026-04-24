# US Stock Tracker — Daily Briefs

Automated public mirror of daily US equity briefs produced by the private [US-Stock-Tracker](https://github.com/nimitmehra/us-stock-tracker) HiveMind pipeline.

## What this is

Each trading day, a Claude Code pipeline runs at 5 PM ET (one hour after US market close):

1. **Gathers intel** — news, market action, SEC filings.
2. **Updates a knowledge graph** — ~40 tracked companies + macro nodes.
3. **Writes a brief** — in the voice of *The Economist's* "World in Brief."
4. **Verifies the brief** — six adversarial checks before publish.
5. **Queues deep research** — async dispatch of full 13-section reports on stocks that cross signal thresholds.

Only the published briefs are mirrored here. The underlying code, graph state, and deep research reports live in the private upstream repo.

## Structure

```
briefs/YYYY-MM-DD.md              Daily brief — TL;DR, What Happened, Action Items,
                                  Trigger Watch, Cascade Watch, Graph Signal
```

## License

Briefs are informational; not investment advice. No warranty. Use at your own risk.
