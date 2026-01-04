# Quick cleanup script
$files = @(
  'C:\code\telemetry-platform\LYRIA_SOFT_EXPERIENCE.md',
  'C:\code\telemetry-platform\DAY5_RELEASE_NOTES.md',
  'C:\code\telemetry-platform\docs\INTERVIEW_QUICK_REFERENCE.md',
  'C:\code\telemetry-platform\docs\SYSTEM_ARCHITECTURE_INTERVIEW_GUIDE.md',
  'C:\code\telemetry-platform\docs\PROFILING_EXERCISE_DAY5.md'
)
foreach ($f in $files) { if (Test-Path $f) { Remove-Item $f -Force; Write-Host "Deleted: $f" } }
Remove-Item 'C:\code\telemetry-platform\docs\archives\development-journey' -Recurse -Force -ErrorAction SilentlyContinue
