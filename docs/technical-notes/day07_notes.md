## Versioning & Releases (Day 7)

- Introduced semantic versioning: v0.1.0 for the first milestone.
- Project version stored in CMake (`project(... VERSION 0.1.0)`).
- Created annotated git tags:
  - v0.1.0 – Week 1 core (Device, TelemetryQueue, GatewayCore, tests).
  - v0.1.1 – Small improvement (print version in gateway_app).
- Published GitHub Releases for each tag with short release notes.
- Practiced:
  - git tag -a / git push origin <tag>
  - git diff v0.1.0..v0.1.1
  - Checking out old releases in detached HEAD to inspect behaviour.
