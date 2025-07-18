# iTech Backend - Render Deployment Script (PowerShell)

Write-Host "🚀 Preparing iTech Backend for Render deployment..." -ForegroundColor Green

# Check if we're in the right directory
if (!(Test-Path "pom.xml")) {
    Write-Host "❌ Error: pom.xml not found. Please run this script from the project root directory." -ForegroundColor Red
    exit 1
}

# Check if git is initialized
if (!(Test-Path ".git")) {
    Write-Host "🔧 Initializing git repository..." -ForegroundColor Yellow
    git init
}

# Add all files
Write-Host "📦 Adding files to git..." -ForegroundColor Cyan
git add .

# Commit changes
Write-Host "💾 Committing changes..." -ForegroundColor Cyan
git commit -m "Configure for Render deployment - Remove Vercel config, add Render config"

# Check if origin is set
try {
    $origin = git remote get-url origin 2>$null
    if ($origin) {
        Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Green
        git push origin main
        Write-Host "✅ Code pushed to GitHub successfully!" -ForegroundColor Green
    } else {
        throw "No origin set"
    }
} catch {
    Write-Host "⚠️  Warning: No remote origin set. Please add your GitHub repository:" -ForegroundColor Yellow
    Write-Host "   git remote add origin https://github.com/yourusername/your-repo.git" -ForegroundColor White
    Write-Host "   Then run: git push -u origin main" -ForegroundColor White
}

Write-Host ""
Write-Host "🎉 Ready for Render deployment!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Go to https://dashboard.render.com" -ForegroundColor White
Write-Host "2. Create a PostgreSQL database" -ForegroundColor White
Write-Host "3. Create a Web Service" -ForegroundColor White
Write-Host "4. Connect your GitHub repository" -ForegroundColor White
Write-Host "5. Set environment variables from .env.render" -ForegroundColor White
Write-Host "6. Deploy!" -ForegroundColor White
Write-Host ""
Write-Host "📖 For detailed instructions, see RENDER_DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan
