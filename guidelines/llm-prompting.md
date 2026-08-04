# LLM API Usage and Prompting

Scope: changed files that call an LLM API or SDK, or that define/edit prompts.

## API calls

- Always set a token limit, using the correct parameter name for that SDK (e.g. `max_tokens` for Anthropic, `max_completion_tokens` for OpenAI).
- Pin the model as an explicit, configurable id — no floating aliases hardcoded across call sites.
- Set an explicit request timeout and a bounded retry policy for transient errors (429, 5xx). Never retry non-transient errors.
- Keep API keys in environment/config, never in source or in prompts.
- Stream only when the consumer actually renders incrementally; otherwise take the simpler non-streaming path.
- Log token usage and latency per call; never log full prompts or completions containing user data.

## Prompt construction

- Build prompts from templates with named placeholders. No string concatenation of user input into instruction text.
- Treat user- and tool-supplied content as data, not instructions: put it in a clearly delimited block and say so in the surrounding instruction.
- Put stable content (system prompt, few-shot examples, long context) first and the variable content last so prefix caching can work.
- State the output contract explicitly — format, required fields, and what to do when the model cannot comply.

## Structured output

- When the caller parses the response, request structured output (tool use / JSON schema / response format) rather than parsing free text.
- Validate every response against a schema before use; handle validation failure as a normal error path, not an assertion.
- Handle truncation: check the stop/finish reason and treat a length-capped response as an error rather than parsing a partial result.

## Testing

- Unit-test the deterministic parts — prompt rendering, response parsing, schema validation, error paths — with recorded fixtures rather than live calls.
- Never let tests hit a live LLM endpoint by default.
