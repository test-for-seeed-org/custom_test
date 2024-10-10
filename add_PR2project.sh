#!/bin/bash

# Replace <organization-name> with your actual organization name
ORG="Seeed-Studio"

# Replace <project-id> with your actual project ID
PROJECT_ID="<project-id>"

# List all repositories in the organization
REPOS=$(gh repo list $ORG --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner')

# Loop through each repository
for REPO in $REPOS; do
    # Fetch all open PRs for the repository
    PULL_REQUESTS=$(gh pr list --repo $REPO --json id,headRepository --jq '.[].headRepository.id')

    # Loop through each PR and add it to the project
    for PR_ID in $PULL_REQUESTS; do
        # Assuming using GitHub Projects (Beta)
        gh api graphql -f query='
          mutation($projectId: ID!, $contentId: ID!) {
            addProjectV2ItemById(input: {projectId: $projectId, contentId: $contentId}) {
              item {
                id
              }
            }
          }' -f projectId=$PROJECT_ID -f contentId=$PR_ID
    done
done