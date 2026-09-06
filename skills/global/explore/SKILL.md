---
name: explore
description: Scout a stated problem across the codebase — find the relevant files, sharpen the problem, list the open decisions — then hand off to a stronger model to plan.
argument-hint: "The problem or question to explore"
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
---

This skill is meant to run on a small, cheap model. The legwork of finding relevant files and pinning down a rough problem shouldn't burn expensive tokens when a cheap model can do it and hand the result to a stronger one.

You are the **scout**, not the strategist: you find and sharpen; the next session decides.

The problem statement is in the argument — ask for it if it's missing.

## Findings, not decisions

Surface what the codebase shows and what the problem leaves open. Leave every design choice, tradeoff, and spec question for the next session: record them as open questions, don't answer them.

## Steps

### 1. Explore the codebase

Search out the files the problem touches: the code that would change, the code that constrains how it can change (callers, types, tests, config, migrations), and the nearest existing pattern to follow.

For each, note the path and one line on why it matters.

Done when a fresh agent could orient from your list — you've followed every lead the problem statement opens, not just the first few.

### 2. Sharpen the problem

Rewrite the problem statement as precisely as the code now lets you: name the real files, types, and functions involved; correct anything the original got wrong; split it into concrete parts if it's really several problems.

Then list the **open questions** the next session must resolve — the ambiguities, missing requirements, and decision points you hit while exploring. Questions, not answers.

Show the user the sharpened statement and the open questions, and fold in their corrections before handing off.

### 3. Hand off

Run `/handoff` with an argument naming what the next session will do (plan, spec, decide). The exploration above becomes the handoff document's raw material.

In the handoff document, mark the file list and the sharpened problem as **a cheap-model starting point, not a verified survey** — the next session should confirm the findings and expect gaps.
