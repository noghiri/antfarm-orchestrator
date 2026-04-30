---
description: Extract YAML frontmatter from a planning document. Called internally by validate-doc and check-staleness. Not typically invoked directly by agents.
user-invocable: false
allowed-tools:
  - Read
---
# Parse Frontmatter

Extract the YAML frontmatter block from a markdown planning document and return it as a structured object.

## Format

Planning documents use Jekyll-style YAML frontmatter delimited by `---`:

```
---
doc_type: feature-design
feature_id: F001
...
---
# Document body starts here
```

## Parsing procedure

1. Read the file using the Read tool.
2. Check that the file begins with `---` on the first line. If not, the document has no frontmatter — return an error.
3. Find the closing `---` delimiter. The frontmatter is everything between the two `---` lines.
4. Parse the frontmatter as YAML.
5. Return the parsed key-value pairs.

## Error cases

- **No frontmatter**: file does not begin with `---`
- **Unclosed frontmatter**: opening `---` has no matching closing `---`
- **Invalid YAML**: frontmatter block is not valid YAML

All error cases must be reported as hard failures to the calling skill.

## Usage

`parse-frontmatter` is called by `validate-doc` and `check-staleness`. It is not typically called directly by agents — use `validate-doc` as the entry point for full document validation.

## Output

Returns a dictionary of key-value pairs from the frontmatter, e.g.:

```json
{
  "doc_type": "feature-design",
  "feature_id": "F001",
  "feature_name": "User Authentication",
  "version": 1,
  "status": "draft",
  "ci_required": false,
  "depends_on_decisions": []
}
```
