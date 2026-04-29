# US Stock Tracker

A production research pipeline for US equities. Scans the market daily, maintains a live knowledge graph of ~40 tracked companies and their macro/sector exposures, writes a Bloomberg-style brief each evening, and dispatches institutional-grade deep research reports when signals cross thresholds — all running inside [Claude Code](https://docs.anthropic.com/en/docs/claude-code), using only free public data (yfinance, SEC EDGAR, Motley Fool).

**Current state**: 42 nodes, 98 edges, automated daily pipeline live since 2026-04-24. The interactive graph viewer is published at [nimitmehra.github.io/us-stock-tracker-briefs/viewer.html](https://nimitmehra.github.io/us-stock-tracker-briefs/viewer.html). Daily briefs mirror at [nimitmehra/us-stock-tracker-briefs](https://github.com/nimitmehra/us-stock-tracker-briefs).

---

## The three layers

The system has grown in three layers, each built on the last. All three work together in the daily pipeline but can also be used standalone.

### Layer 1 — Screening (`scan_earnings.py` → `screen_us_pipeline.py`)

The original scan-and-screen pipeline. Hits the SEC EDGAR EFTS API to find recent earnings filers, then runs each through a 5-track gate system sized to its sector (Traditional/Growth/Financial/Biotech/Commodity). Surfaces the candidates worth deeper research.

### Layer 2 — Deep Research (sector-specific prompts)

Four prompts (+ a 3-agent critical review) that turn Claude Code itself into the analyst. Each produces a 13-section report with industry map, ownership, earnings-call verbatim, bull/bear cases, Kill Sheet + Munger Inversion, scenario analysis with probability-weighted IRRs, and concrete action triggers.

| Prompt | Use for | Key metrics |
|--------|---------|-------------|
| `deep_research_prompt.md` | Energy, defense, shipping, industrials, consumer | EV/EBITDA, FCF yield, ROIC |
| `deep_research_prompt_growth.md` | Tech, SaaS, semiconductors, AI | EV/Revenue, Rule of 40, P/FCF |
| `deep_research_prompt_financials.md` | Banks, insurance, fintech, REITs | P/TBV, ROE, NIM, CET1 |
| `deep_research_prompt_biotech.md` | Pharma, biotech, clinical-stage | Pipeline NPV, patent cliff, PoS |
| `.claude/commands/critical-review.md` | 3-agent adversarial stress test on every BUY | Question-master → truth-seeker → prioritizer |

60+ deep research reports live in `deep_research_reports/`.

### Layer 3 — HiveMind (`hive-mind/`)

The persistent knowledge graph that watches Tier 1 stocks continuously between quarterly deep research runs. Nodes for tracked tickers, macros (Fed rates, AI disruption, oil, tariffs), sectors, commodities. Edges capture mechanism-specific exposures verifiable from a source DR report — not assumptions. A daily signals-cascade-edges update is produced by `/update-graph`, surfaced by `/write-brief`, verified by `/verify-brief`, and auto-dispatched to further deep research by `/trigger-dr` when a node crosses a trigger-point.

Architectural blueprint: `ARCHITECTURE.md`. Per-node audit trails: `hive-mind/graph/nodes/extraction_reports/`.

---

## The daily pipeline

Runs unattended via cron at 2:30 AM IST weekdays (= 5 PM ET EDT, one hour after US close):

```
/market-brief orchestrator
  ├─ Step 0   Broad-scan EDGAR for new filers (50-150 tickers/day)
  ├─ Step 1   /gather-intel (parallel: /news-intel + /market-action + /sec-pipeline-intel)
  ├─ Step 2   /update-graph  — ingest signals, cascade to macros, fire triggers
  ├─ Step 3   /write-brief   — narrative brief in Economist "World in Brief" voice
  ├─ Step 4   /verify-brief  — six adversarial checks before publish
  ├─ Step 5   /trigger-dr    — drain DR queue (10/day, 50/week Phase 2 cap)
  └─ Step 6   Push private repo + rsync briefs/viewer to public mirror
```

Typical runtime: 90–150 minutes. Output: `briefs/YYYY-MM-DD.md` + mutations to `hive-mind/graph/nodes/*.json` + fresh DR reports.

**Scripts**: `scripts/run-us-market-brief.sh`, `scripts/run-us-trigger-dr.sh`. Cron-installed. Wake schedule via `pmset repeat wakeorpoweron` ensures the Mac is up at fire time.

---

## Using individual components

### Screening

```bash
python run_us_pipeline.py                             # Full scan + screen, last 7 days
python run_us_pipeline.py --days 14 --include-watchlist
python screen_us_pipeline.py --symbol FANG LNG NVDA JPM
python screen_us_pipeline.py --universe sp500_sample  # ~100 representative names
```

### Data fetchers

```bash
python fetch_stock_data.py --symbol FANG LNG CF RTX
python fetch_stock_data.py --symbol FANG --full       # Quarterly financials
python fetch_sec_filings.py --symbol FANG --financials --insiders
python fetch_earnings_transcripts.py --symbol FANG --quarter Q4 --year 2025
```

### Deep research (inside Claude Code)

```
/deep-research-us       FANG Q4 2025
/deep-research-growth   NVDA Q4 2025
/deep-research-financials JPM Q4 2025
/deep-research-biotech  LLY Q4 2025
/critical-review        FANG Q4 2025    # 3-agent stress test — only for BUY-rated
```

### HiveMind pipeline (inside Claude Code)

```
/market-brief      # Full daily pipeline — typically run via cron
/trigger-dr        # Drain the deep-research queue
/update-graph      # Mutate nodes from today's intel
/write-brief       # Compose the daily brief
/verify-brief      # Adversarial check
```

---

## Setup

```bash
git clone https://github.com/nimitmehra/us-stock-tracker.git
cd us-stock-tracker
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python db.py --init
```

**SEC EDGAR identity** (required for SEC API access): set a valid contact email in `fetch_sec_filings.py` line 36 — SEC requires it in the User-Agent header.

---

## Repository structure

```
.
├── scan_earnings.py, screen_us_pipeline.py, run_us_pipeline.py    Layer 1 — screening
├── deep_research_prompt*.md                                       Layer 2 — DR prompts
├── .claude/commands/                                              Slash-command shims
├── hive-mind/
│   ├── graph/nodes/*.json        Knowledge graph state (42 nodes)
│   ├── graph/meta.json           Graph statistics
│   ├── skills/                   /market-brief, /update-graph, /write-brief, etc.
│   ├── scripts/                  Viewer rebuild, market-data fetch, broad-scan
│   └── viewer.html               Interactive Cytoscape graph
├── briefs/YYYY-MM-DD.md          Daily published briefs
├── deep_research_reports/        60+ DR reports + critical-review addenda
├── staging/YYYY-MM-DD/           Per-run intel artifacts
├── scripts/                      Cron scripts (market-brief + trigger-dr)
├── fetch_*.py                    Data fetchers (yfinance, SEC, Motley Fool)
├── db.py                         SQLite schema + status
└── ARCHITECTURE.md               HiveMind design doc
```

---

## Design principles

- **No external AI API costs**. Claude Code *is* the analyst. The pipeline makes no LLM API calls outside the Claude Code subscription.
- **Free data only**. yfinance, SEC EDGAR, Motley Fool scraping. No paid feeds.
- **Verify everything**. Never rely on training data for factual claims. Web-search all non-obvious numbers.
- **No Until Yes**. Every stock starts as a PASS. Three gates of evidence earn a deeper look.
- **Source-grounded edges**. HiveMind edges are created only when their mechanism is verifiable from a specific stock's deep research. Illustrative examples are schema, not evidence.
- **Cross-step coherence**. Individual-file validity is never enough; the orchestrator owns pipeline-level coherence.

---

## License

MIT. Research only — not investment advice, no warranty.
