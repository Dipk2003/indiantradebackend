#!/bin/bash

# iTech Backend - Render Deployment Script

echo "🚀 Preparing iTech Backend for Render deployment..."

# Check if we're in the right directory
if [ ! -f "pom.xml" ]; then
    echo "❌ Error: pom.xml not found. Please run this script from the project root directory."
    exit 1
fi

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "🔧 Initializing git repository..."
    git init
fi

# Add all files
echo "📦 Adding files to git..."
git add .

# Commit changes
echo "💾 Committing changes..."
git commit -m "Configure for Render deployment - Remove Vercel config, add Render config"

# Check if origin is set
if ! git remote get-url origin &>/dev/null; then
    echo "⚠️  Warning: No remote origin set. Please add your GitHub repository:"
    echo "   git remote add origin https://github.com/yourusername/your-repo.git"
    echo "   Then run: git push -u origin main"
else
    echo "🚀 Pushing to GitHub..."
    git push origin main
    echo "✅ Code pushed to GitHub successfully!"
fi

echo ""
echo "🎉 Ready for Render deployment!"
echo ""
echo "Next steps:"
echo "1. Go to https://dashboard.render.com"
echo "2. Create a PostgreSQL database"
echo "3. Create a Web Service"
echo "4. Connect your GitHub repository"
echo "5. Set environment variables from .env.render"
echo "6. Deploy!"
echo ""
echo "📖 For detailed instructions, see RENDER_DEPLOYMENT_GUIDE.md"
