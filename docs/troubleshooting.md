# Troubleshooting CI/CD Issues

## Problem: Failing `windows-gui` Job in GitHub Actions

### Symptoms

The `windows-gui` job in the `.github/workflows/cpp-ci.yml` workflow was consistently failing during the Qt installation step. The primary error messages were:

1.  **`The packages ['qt_base'] were not found`**: This error occurred both when using the `jurplel/install-qt-action` and when attempting manual installation with `aqtinstall`. It indicates that the combination of Qt version, host OS, and architecture provided to the installer did not match a valid, available Qt distribution.

2.  **`EACCES: permission denied, stat 'C:\Users\runneradmin\AppData\Local\Microsoft\WindowsApps\python.EXE'`**: This was an intermittent error related to the Python executable on the GitHub-hosted Windows runner. It appears to be a permissions issue with the default Python installation or stubs provided in the runner environment.

### Debugging and Resolution Path

We took the following steps to diagnose and resolve the issue:

1.  **Initial Attempts with `jurplel/install-qt-action`**:
    *   We tried various `arch` values, such as `win64_msvc2022_64` and `msvc2022_64`.
    *   We experimented with different patch versions of Qt.
    *   These attempts were unsuccessful and continued to produce the `qt_base not found` error, suggesting the action itself might be unreliable or have an obscure argument combination.

2.  **Pivoting to Manual Installation with `aqtinstall`**:
    *   To gain more control, we decided to abandon the `jurplel/install-qt-action` and replicate its functionality manually.
    *   This involved adding steps to the workflow to:
        a. Set up a specific Python version using `actions/setup-python@v5`. This also resolved the `EACCES` error by ensuring we were using a clean, correctly-pathed Python installation.
        b. Install `aqtinstall` via `pip`.
        c. Execute `aqtinstall` directly from a workflow step.

3.  **Refining the `aqtinstall` Command**:
    *   Our first manual attempts failed due to an incorrect command (`aqtinstall-windows-desktop` instead of the correct `aqt install-qt`).
    *   Subsequent failures were due to using the incorrect architecture string (`win64_msvc2022_64`).

### Final Solution

The final, working solution was to replace the `jurplel/install-qt-action` step with the following sequence of steps in the `windows-gui` job:

```yaml
# 1. Define the architecture in the job's environment
env:
  QT_HOST: windows
  QT_ARCH: msvc2022_64 # Note: not 'win64_msvc2022_64'

# ... inside steps:

# 2. Set up a stable Python environment
- name: Install Python for aqtinstall
  uses: actions/setup-python@v5
  with:
    python-version: '3.11'

# 3. Install the aqtinstall tool
- name: Install aqtinstall
  run: pip install "aqtinstall==3.3.*"

# 4. Run aqtinstall and set environment variables for subsequent steps
- name: Install Qt
  shell: pwsh
  run: |
    aqt install-qt windows desktop 6.5.3 ${{ env.QT_ARCH }} -O ${{ github.workspace }}/qt
    echo "Qt6_DIR=${{ github.workspace }}/qt/6.5.3/${{ env.QT_ARCH }}/lib/cmake/Qt6" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    echo "${{ github.workspace }}/qt/6.5.3/${{ env.QT_ARCH }}/bin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append

# 5. Add a guardrail to verify the installation
- name: Guardrail: Verify Qt was installed
  shell: pwsh
  run: |
    $ErrorActionPreference = 'Stop'
    if (-not (Test-Path $env:Qt6_DIR)) {
      throw "Qt6_DIR not found at '$env:Qt6_DIR'"
    }
    Write-Host "Qt6_DIR found at $env:Qt6_DIR"
    Get-Command windeployqt.exe
```

This approach proved to be stable and resolved all the CI failures related to Qt installation.
