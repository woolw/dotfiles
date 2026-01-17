# Hardware Issue Documentation

This directory contains detailed documentation for hardware-specific issues and their solutions on this system.

## Purpose

When encountering hardware quirks, driver issues, or device-specific problems, document them here with:
- Clear problem description
- Root cause analysis
- Working solution
- Verification steps
- Important notes and caveats

## Template

Use this template for new hardware issue reports:

```markdown
# [Hardware Component] - [Issue Name]

**Status**: SOLVED | WORKAROUND | UNSOLVED
**Date Documented**: YYYY-MM-DD
**Affected System**: NixOS Desktop | macOS | Both

---

## Problem

Brief description of the symptom and how it manifests.

## Root Cause

Technical explanation of why this happens.

## Solution

Implementation details and code snippets.

\`\`\`nix
# NixOS configuration snippet
\`\`\`

## Verification

\`\`\`bash
# Commands to verify the fix is working
\`\`\`

**Expected output:**
\`\`\`
# What you should see
\`\`\`

## Notes

- Any important caveats
- Alternative solutions that didn't work
- Related issues or considerations
- Links to upstream bug reports

## Hardware Details

- **Device**: [lspci/lsusb output or identifier]
- **Driver**: [driver name and version]
- **Kernel**: [kernel version where issue occurs/is fixed]
- **Additional Info**: [any other relevant details]

## Related Links

- [Links to NixOS modules]
- [Upstream documentation]
- [Bug reports]
```

## Documented Issues

- [AMD RX 7900 XT Display Artifacts](./amd-rx7900xt-display-artifacts.md) - ✅ SOLVED
