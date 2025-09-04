# 🎨 iTech Frontend - AWS Amplify Deployment Instructions

## Prerequisites
- AWS CLI installed and configured
- Git repository with your frontend code
- Domain name (optional)

## Step 1: Prepare Frontend Code
```bash
# Navigate to frontend directory
cd "C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main"

# Copy amplify configuration
cp path/to/frontend-amplify-config.yml ./amplify.yml

# Test build locally
npm install
npm run build:production
```

## Step 2: Push Code to Git Repository
```bash
# Initialize git (if not already)
git init
git add .
git commit -m "Initial commit for AWS deployment"

# Push to GitHub/GitLab/CodeCommit
git remote add origin https://github.com/yourusername/itech-frontend.git
git push -u origin main
```

## Step 3: Setup AWS Amplify Application

### Option A: Using AWS Console
1. Go to AWS Amplify Console
2. Click "New app" → "Host web app"
3. Choose your Git provider (GitHub/GitLab/CodeCommit)
4. Select your repository and branch
5. Configure build settings:
   - Build command: `npm run build:production`
   - Output directory: `.next`
   - Node.js version: 18.x

### Option B: Using AWS CLI
```bash
# Create Amplify app
aws amplify create-app \
  --name itech-frontend \
  --repository https://github.com/yourusername/itech-frontend \
  --oauth-token your-github-token

# Create branch
aws amplify create-branch \
  --app-id your-app-id \
  --branch-name main \
  --build-spec file://amplify.yml
```

## Step 4: Configure Environment Variables
In AWS Amplify Console → App settings → Environment variables, add all variables from `frontend-env-variables.txt`:

**Key Variables to Update:**
```
NEXT_PUBLIC_API_BASE_URL=https://your-backend-eb-url.elasticbeanstalk.com
NEXT_PUBLIC_FRONTEND_URL=https://your-app-id.amplifyapp.com
```

## Step 5: Configure Build Settings
```yaml
# amplify.yml (already created)
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - npm ci
    build:
      commands:
        - npm run build:production
  artifacts:
    baseDirectory: .next
    files:
      - '**/*'
```

## Step 6: Deploy Application
```bash
# Trigger deployment
aws amplify start-job \
  --app-id your-app-id \
  --branch-name main \
  --job-type RELEASE
```

Or simply push to your git repository - Amplify will auto-deploy.

## Step 7: Configure Custom Domain (Optional)
1. Go to Amplify Console → Domain management
2. Add domain name
3. Configure DNS with your domain provider
4. SSL certificate will be auto-provisioned

## Step 8: Setup Redirects & Rewrites
In Amplify Console → Rewrites and redirects:
```
Source: /<*>
Target: /index.html
Type: 200 (Rewrite)
Country code: 
```

## Verification Steps
```bash
# Check deployment status
aws amplify list-jobs --app-id your-app-id --branch-name main

# Test frontend
curl https://your-app-id.amplifyapp.com

# Test API connection
# Open browser → https://your-app-id.amplifyapp.com
# Check if it can connect to backend APIs
```

## Performance Optimization
1. Enable compression in Amplify
2. Configure CDN caching
3. Enable performance monitoring
4. Setup custom headers for security

## Troubleshooting
- Check build logs in Amplify Console
- Verify environment variables
- Test API endpoints separately
- Check CORS configuration in backend
