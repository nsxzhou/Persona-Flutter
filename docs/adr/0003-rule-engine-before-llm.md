# ADR-0003: Rule Engine Before LLM for Recommendation Generation

The recommendation generation pipeline uses a two-stage serial architecture: the Rule Engine first computes quantitative metrics from Market Scan Data (genre heat, frequency distributions, competitive density, market opportunity scores), then the LLM receives these structured metrics as context to generate 3-5 creative Recommendation Directions.

We chose serial over parallel because the LLM's creative output is materially better when grounded in specific quantitative signals — genre heat and opportunity scores give the LLM concrete constraints to work within, producing more actionable recommendations than raw data or unconstrained generation. A pure LLM approach (sending raw market data directly) was rejected because LLMs are poor at statistical aggregation compared to the deterministic Rule Engine, and the token cost of passing large raw datasets is prohibitive.
