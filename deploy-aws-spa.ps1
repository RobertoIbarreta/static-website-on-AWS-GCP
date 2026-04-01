param(
  [Parameter(Mandatory = $true)]
  [string]$BucketName,

  [Parameter(Mandatory = $true)]
  [string]$DistributionId,

  [string]$BuildDir = "dist",

  # Optional: run your build command before upload
  [switch]$RunBuild,

  [string]$BuildCommand = "npm run build"
)

$ErrorActionPreference = "Stop"

Write-Host "==> Starting SPA deploy to AWS" -ForegroundColor Cyan
Write-Host "Bucket: $BucketName"
Write-Host "Distribution: $DistributionId"
Write-Host "BuildDir: $BuildDir"

if ($RunBuild) {
  Write-Host "==> Running build command: $BuildCommand" -ForegroundColor Yellow
  Invoke-Expression $BuildCommand
}

if (-not (Test-Path $BuildDir)) {
  throw "Build directory '$BuildDir' not found."
}

# 1) Upload everything first (safe baseline)
Write-Host "==> Syncing build files to S3" -ForegroundColor Yellow
aws s3 sync $BuildDir "s3://$BucketName" --delete

# 2) Ensure index.html is always fresh
$indexPath = Join-Path $BuildDir "index.html"
if (Test-Path $indexPath) {
  Write-Host "==> Uploading index.html with no-cache headers" -ForegroundColor Yellow
  aws s3 cp $indexPath "s3://$BucketName/index.html" `
    --cache-control "no-cache, no-store, must-revalidate" `
    --content-type "text/html"
}

# 3) Optional: also set 404.html no-cache if exists
$notFoundPath = Join-Path $BuildDir "404.html"
if (Test-Path $notFoundPath) {
  Write-Host "==> Uploading 404.html with no-cache headers" -ForegroundColor Yellow
  aws s3 cp $notFoundPath "s3://$BucketName/404.html" `
    --cache-control "no-cache, no-store, must-revalidate" `
    --content-type "text/html"
}

# 4) Invalidate CloudFront cache
Write-Host "==> Creating CloudFront invalidation" -ForegroundColor Yellow
aws cloudfront create-invalidation `
  --distribution-id $DistributionId `
  --paths "/" "/index.html"

Write-Host "==> Deploy completed successfully." -ForegroundColor Green