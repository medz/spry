# AGENTS

This file defines repository-level writing and release rules for humans and agents working on Spry.

## Scope

These rules apply to:

- commits
- pull requests
- changelog entries
- GitHub release notes
- release preparation work

## Commit Rules

Use Conventional Commits.

Preferred types:

- `feat`
- `fix`
- `docs`
- `refactor`
- `perf`
- `test`
- `build`
- `ci`
- `chore`

Use a scope when it improves clarity.

Examples:

- `feat(routing): adopt roux 0.5 path syntax`
- `fix(scanner): reject param-name drift in route shapes`
- `docs(changelog): align v8 entry with release notes`

Use `BREAKING CHANGE:` in the footer when a commit introduces a breaking API or behavior change.

## Pull Request Rules

PR titles should also use Conventional Commit style.

Examples:

- `feat(http): upgrade to ht 0.3 and osrv 0.4`
- `chore(release): prepare v8.0.0`

Default PR body rule:

- leave the body empty unless the PR directly resolves a tracked issue

If the PR resolves an issue, use:

```text
Resolves #<id>
```

## Changelog Rules

`CHANGELOG.md` is the long-lived project record.

Each release entry should use this structure:

```md
## vX.Y.Z

**Migration guide**: <link-if-needed>

### Highlights

Short release summary.

### Breaking Changes

- User-facing breaking changes only.

### What's New

#### <Area>

- User-facing additions and improvements.

### Migration note

- Concrete upgrade actions.

### Full Changelog

- Compare link.
```

Changelog writing rules:

- optimize for historical accuracy over marketing copy
- group changes by user-facing area, not by internal commit order
- include author attribution and source references when useful
- prefer PR links when available
- use commit links only when work landed without a PR

Attribution format in `CHANGELOG.md`:

- `by [@medz](https://github.com/medz) in [#157](https://github.com/medz/spry/pull/157)`
- `by [@medz](https://github.com/medz) in [13fed0d](https://github.com/medz/spry/commit/13fed0d99e266f138ac84d62d44a4014229070c1)`

## Release Rules

GitHub Releases use the same structure and ordering as `CHANGELOG.md`:

- `Highlights`
- `Breaking Changes`
- `What's New`
- `Migration Guide`
- `Full Changelog`

Release writing rules:

- optimize for the current release announcement, not for long-term archival wording
- keep the summary tighter than the changelog entry
- describe real user-facing changes only
- avoid raw commit lists as the main body

Attribution format in GitHub Releases:

- prefer native GitHub mentions such as `@medz`
- prefer PR references such as `#157`
- use commit hashes only when no PR exists

## Changelog vs Release

The changelog and release body should contain the same substantive change summary.

The main formatting difference is attribution style:

- `CHANGELOG.md` should use explicit markdown links for people, PRs, and commits
- GitHub Releases should use native GitHub references such as `@user` and `#123` so GitHub links them automatically

## Release Preparation Checklist

Before publishing a new version:

1. update `pubspec.yaml`
2. finalize the release entry in `CHANGELOG.md`
3. update migration docs when the release has breaking changes
4. verify docs and release-facing branding if versioned wording exists
5. run `dart test`
6. run `dart pub publish --dry-run`
7. build the docs site
8. check CI on `main`
9. smoke-test key examples when the release changes runtime/build behavior
10. create and push the release tag
11. publish to pub.dev
12. create or update the GitHub Release body using the same structure
