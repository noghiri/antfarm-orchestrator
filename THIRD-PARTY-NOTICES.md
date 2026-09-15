# Third-Party Notices

This project incorporates or adapts material from the following third-party sources.
The MIT license in `LICENSE` covers all files in this repository **except** where noted
below.

---

## 1. claude-code-modes (MIT)

**Files:**
- `prompts/fragments/axis/` — source fragment files
- The corresponding axis sections embedded verbatim in `prompts/assembled/` (the
  `# Agency: …`, `# Quality: …`, and `# Scope: …` sections)

**Source:** https://github.com/nklisch/claude-code-modes  
**Author:** @nklisch  
**License:** MIT License

The behavioral preset system — the agency/quality/scope axes and the
fragment-based prompt assembly approach — is adapted from claude-code-modes.

The MIT License requires the copyright notice and permission notice to be preserved
in redistributed copies. The full copyright notice (including year) should be verified
at the upstream repository; the license text is reproduced here:

> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all
> copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.

---

## 2. ed3d-plugins — rust-guide (CC BY-SA 4.0)

**Files:** `plugins/house-style/skills/rust-guide/`

**Source:** https://github.com/ed3dai/ed3d-plugins  
**Author:** Ed Ropple and contributors  
**License:** Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)

The `rust-guide` skill is a derivative work of the `howto-code-in-rust` skill in
ed3d-plugins. This component is **not** covered by the MIT license. It is distributed
under CC BY-SA 4.0 as documented in
[`plugins/house-style/LICENSE.cc-by-sa-4.0`](plugins/house-style/LICENSE.cc-by-sa-4.0).

Any adaptation of this skill must also be distributed under CC BY-SA 4.0 per the
ShareAlike requirement. MIT is not a Compatible License for CC BY-SA 4.0 purposes.

Full license text: https://creativecommons.org/licenses/by-sa/4.0/legalcode

---

## 3. ed3d-plugins — inspiration (courtesy attributions, MIT)

The following skills were **independently written** but conceptually inspired by
ed3d-plugins skills. They are original works and are covered by the MIT license.
The in-file attribution notes are courtesy acknowledgements, not license obligations.

| Skill file | Inspired by |
|---|---|
| `plugins/house-style/skills/coding-principles/SKILL.md` | `coding-effectively` |
| `plugins/house-style/skills/defense-in-depth/SKILL.md` | `defense-in-depth` |
| `plugins/agent-skills/skills/research/SKILL.md` | `researching-on-the-internet` |
