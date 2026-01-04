# Quick cleanup script for telemetry-platform
$files = @(
  'C:\code\telemetry-platform\LYRIA_SOFT_EXPERIENCE.md',
  'C:\code\telemetry-platform\DAY5_RELEASE_NOTES.md',
  'C:\code\telemetry-platform\docs\INTERVIEW_QUICK_REFERENCE.md',
  'C:\code\telemetry-platform\docs\SYSTEM_ARCHITECTURE_INTERVIEW_GUIDE.md',
  'C:\code\telemetry-platform\docs\PROFILING_EXERCISE_DAY5.md',
  'C:\code\telemetry-platform\ingestion\docs\amaresh_career_context.md',
  'C:\code\telemetry-platform\ingestion\docs\career_decision_journal.md',
  'C:\code\telemetry-platform\ingestion\docs\cover_letter_booking_backend_engineer.md',
  'C:\code\telemetry-platform\ingestion\docs\cover_letter_kubota_sensor_engineer.md',
  'C:\code\telemetry-platform\ingestion\docs\cv_improvement_guide_amaresh.md',
  'C:\code\telemetry-platform\ingestion\docs\day19_career_strategy.md',
  'C:\code\telemetry-platform\ingestion\docs\day19_cv_recommendations.md',
  'C:\code\telemetry-platform\ingestion\docs\day19_interaction_log.md',
  'C:\code\telemetry-platform\ingestion\docs\day19_interview_guidance.md',
  'C:\code\telemetry-platform\ingestion\docs\distqueue_day1_status.md',
  'C:\code\telemetry-platform\ingestion\docs\job_analysis_alpha_credit.md',
  'C:\code\telemetry-platform\ingestion\docs\linkedin_about_natural.md',
  'C:\code\telemetry-platform\ingestion\docs\linkedin_about_section.md',
  'C:\code\telemetry-platform\ingestion\docs\linkedin_job_search_strategy.md',
  'C:\code\telemetry-platform\ingestion\docs\medium_post_telemetryhub.md',
  'C:\code\telemetry-platform\ingestion\docs\migration_log.md',
  'C:\code\telemetry-platform\ingestion\docs\next_project_strategy.md',
  'C:\code\telemetry-platform\ingestion\docs\reframing_complete_summary.md',
  'C:\code\telemetry-platform\ingestion\docs\resume_content_updated_telemetrytaskprocessor.md',
  'C:\code\telemetry-platform\ingestion\docs\telemetrytaskprocessor_reframe_plan.md',
  'C:\code\telemetry-platform\ingestion\FIX_DAY19_ISSUE.md',
  'C:\code\telemetry-platform\processing\docs\day1_complete.md',
  'C:\code\telemetry-platform\processing\docs\day1_implementation.md'
)

$deleted = 0
foreach ($f in $files) {
    if (Test-Path $f) {
        Remove-Item $f -Force
        Write-Host "✅ Deleted: $($f.Replace('C:\code\telemetry-platform\', ''))" -ForegroundColor Green
        $deleted++
    }
}

# Delete development-journey directory
if (Test-Path 'C:\code\telemetry-platform\docs\archives\development-journey') {
    Remove-Item 'C:\code\telemetry-platform\docs\archives\development-journey' -Recurse -Force
    Write-Host "✅ Deleted: docs\archives\development-journey\" -ForegroundColor Green
    $deleted++
}

Write-Host "" 
Write-Host "Cleanup complete: $deleted items deleted" -ForegroundColor Cyan
