## [1.0.4] - 2026-02-25

### 📚 Documentation
- Added `docs/architecture.md` — architecture guidance and operational checklist
- Added `docs/io.md` — full inputs/outputs reference table

### 💡 Examples
- Added `_examples/terragrunt/` — Terragrunt example with DO Spaces remote state and OpenTofu support

### 👷 CI/CD & GitHub
- Added `.github/ISSUE_TEMPLATE/` — bug report, feature request, and config templates
- Added `SECURITY.md` — vulnerability reporting policy
- Standardized all workflow SHA pins and removed `workflows.old/`
- Upgraded `.pre-commit-config.yaml` to gruntwork-io/pre-commit v0.1.23 and pre-commit-hooks v4.5.0

## [1.0.1] - 2026-02-06

### Changes
- Merge pull request #12 from terraform-do-modules/fix/upgrade-and-workflows
- 🐛 fix: correct output reference to uuid instead of resource_alert_id
- 🐛 fix: correct VPC module version to 1.0.0
- ✨ feat: add complete example and update provider versions in all examples
- ⬆️ Upgrade provider & standardize workflows
- chore: standardize GitHub Actions workflows and fix code issues
- fix: updated tf-checks.yml
- fix: updated workflow & versions of examples
- Merge pull request #8 from terraform-do-modules/feat/auto-merge
- feat: added automerge and updated the workflows
- Merge pull request #6 from terraform-do-modules/fix/-depndabot-workflow-issue
- fix
- Merge pull request #1 from terraform-do-modules/internal-431
- fix: add basic and complete example
- fix: rename examples name

