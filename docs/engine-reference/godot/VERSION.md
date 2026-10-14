# Godot Engine — Version Reference

| Field | Value |
|-------|-------|
| **Engine Version** | Godot 4.7.2 |
| **Installed at pin time** | 4.7.2.stable.official.ed1daf0bf — installed 2026-10-14 at `~/.local/share/godot/4.7.2/`, linked as `~/.local/bin/godot` (matches pin) |
| **Release Date** | 4.7: 2026-06-18 · 4.7.2: 2026-08-18 |
| **Project Pinned** | 2026-10-14 |
| **Last Docs Verified** | 2026-10-14 (4.6→4.7 migration guide only; earlier spans last verified 2026-02-12) |
| **LLM Knowledge Cutoff** | May 2025 |

## Knowledge Gap Warning

The LLM's training data likely covers Godot up to ~4.3. Versions 4.4, 4.5,
4.6 and 4.7 introduced significant changes that the model does NOT know about.
Always cross-reference this directory before suggesting Godot API calls.

## Installed-Version Gap Warning

The warning above is one-directional — it covers the **model** knowing less than
this pin. The reverse gap is real and `/setup-engine` §3 creates it deliberately
("pin the newer one and upgrade later"): this reference can sit **ahead of the
installed editor**, and an agent citing it correctly then emits APIs that do not
compile locally. **Check `Installed at pin time` above before trusting a
version-qualified claim** — `NOT DETERMINED` means the gap is unknown, not absent.

## Post-Cutoff Version Timeline

| Version | Release | Risk Level | Key Theme |
|---------|---------|------------|-----------|
| 4.4 | ~Mid 2025 | MEDIUM | Jolt physics option, FileAccess return types, shader texture type changes |
| 4.5 | ~Late 2025 | HIGH | Accessibility (AccessKit), variadic args, @abstract, shader baker, SMAA |
| 4.6 | Jan 2026 | HIGH | Jolt default, glow rework, D3D12 default on Windows, IK restored |
| 4.7 | 2026-06-18 (4.7.2: 2026-08-18) | HIGH | Stretch-mode defaults for new projects, input device ID constants, typed-override return rule, AccessibilityServer, RichTextLabel image units |

## Verified Sources

- Official docs: https://docs.godotengine.org/en/stable/
- 4.5→4.6 migration: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.6.html
- 4.4→4.5 migration: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.5.html
- Changelog: https://github.com/godotengine/godot/blob/master/CHANGELOG.md
- Release notes: https://godotengine.org/releases/4.6/
- 4.6→4.7 migration: https://docs.godotengine.org/en/4.7/tutorials/migrating/upgrading_to_godot_4.7.html
- 4.7.2 maintenance release: https://godotengine.org/article/maintenance-release-godot-4-7-2/
- 4.7 release notes page (https://godotengine.org/releases/4.7/): NOT SOURCEABLE this run — fetch timed out; new-feature highlights for 4.7 are not recorded here.
