<#
Apply Windows ACLs to make `tmp`, `log`, and `storage` writable for Docker containers.

Usage (PowerShell - run from repo root):
  ./scripts/fix-permissions.ps1

This grants the built-in "Users" group Modify permissions recursively so a non-root
container user (like uid 1000 used by this app image) can write to the mounted
directories. Run this once after cloning or when permission errors occur.

Note: This modifies ACLs on your filesystem. It's intended for local development only.
#>

param()

Write-Host "Applying permissions to tmp, log, and storage directories..." -ForegroundColor Cyan

$paths = @("tmp", "log", "storage")

foreach ($p in $paths) {
    $full = Join-Path -Path (Get-Location) -ChildPath $p
    if (-not (Test-Path $full)) {
        Write-Host "Creating directory: $full"
        New-Item -ItemType Directory -Path $full | Out-Null
    }

    Write-Host "Granting Modify to 'Users' on $full (recursively)"
    try {
        # Grant Modify to Users group recursively
        icacls $full /grant "Users:(OI)(CI)M" /T | Out-Null
        # Ensure propagation of inherited permissions
        icacls $full /setintegritylevel (OI)(CI) low | Out-Null
    } catch {
        Write-Host "Warning: Failed to set ACL for $full: $_" -ForegroundColor Yellow
    }
}

Write-Host "Permissions applied. You can now run Docker Compose without needing the container to chown files." -ForegroundColor Green
