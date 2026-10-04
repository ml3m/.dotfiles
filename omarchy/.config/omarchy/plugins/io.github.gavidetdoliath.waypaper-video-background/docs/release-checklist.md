# Release checklist

## Repository

- [ ] Confirm the permanent plugin ID and GitHub repository name.
- [ ] Review README, license, preview ownership, and external dependencies.
- [ ] Run `./validate.sh` on the supported Omarchy Quattro release.
- [ ] Test install, enable, video selection, restart, update, rollback, and remove.
- [ ] Confirm no personal paths, videos, sockets, logs, or credentials are tracked.

## Release

- [ ] Update `manifest.json` and `CHANGELOG.md` with the same version.
- [ ] Keep the default branch installable before pushing.
- [ ] Create an annotated `v<version>` tag and a matching GitHub release.
- [ ] Test `omarchy plugin add <public-git-url>` from the public repository.

## Marketplace

- [ ] Search the registry again for the permanent plugin ID.
- [ ] Confirm all submission checklist statements with the owner.
- [ ] Submit the prepared issue and review automated compatibility/security output.
- [ ] Address feedback in the existing issue rather than opening a duplicate.
