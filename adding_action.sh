#!/bin/bash

# Set variables
GITHUB_USER="MatthewJeffson"  # Replace with your GitHub username
GITHUB_ORG="Seeed-Studio"       # Replace with your GitHub organization name if applicable

# Ensure GitHub CLI is authenticated
if ! gh auth status; then
  echo "GitHub CLI is not authenticated. Please authenticate using 'gh auth login'."
  exit 1
fi

# Fetch all repositories for the user or organization
gh repo list $GITHUB_ORG --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner' | while read repo
do
  echo "Processing $repo..."
  repo_name=$(basename "$repo")
  
  # Clone the repository (shallow clone)
  git clone --depth 1 "https://github.com/$repo.git" || { echo "Failed to clone $repo"; continue; }
  
  cd $repo_name

  # Create the workflows directory if it doesn't exist
  mkdir -p .github/workflows

  # Ensure sync_issues.yml is in the parent directory or adjust the path accordingly
  if [ -f ../sync_issues.yml ]; then
    cp ../sync_issues.yml .github/workflows/
  else
    echo "sync_issues.yml does not exist in the expected location."
    cd ..
    continue
  fi

  # Git operations
  git add .github/workflows/sync_issues.yml
  git commit -m "Add sync_issues GitHub Action for workflows"
  git push || echo "Failed to push changes to $repo"

  # Go back to the root directory
  cd ..
done