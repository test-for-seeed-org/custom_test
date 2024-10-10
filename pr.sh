#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
ORG="Seeed-Studio"
PROJECT_NAME="Issues Assemble"

# Function to fetch all projects and find the project ID by name
get_project_id() {
  gh api graphql -f query='
    query($org: String!) {
      organization(login: $org) {
        projectsV2(first: 100) {
          nodes {
            id
            title
          }
        }
      }
    }
  ' -f org="$ORG" --jq ".data.organization.projectsV2.nodes[] | select(.title == \"$PROJECT_NAME\") | .id"
}

# Function to check if a PR is already in the project
is_pr_in_project() {
  local pr_number="$1"
  gh api graphql -f query='
    query($projectId: ID!, $prNumber: Int!) {
      node(id: $projectId) {
        ... on ProjectV2 {
          items(first: 100, filter: { labels: [{ name: "pull_request" }, { number: $prNumber }] }) {
            nodes {
              content {
                ... on PullRequest {
                  number
                }
              }
            }
          }
        }
      }
    }
  ' -f projectId="$PROJECT_ID" -f prNumber="$pr_number" --jq '.data.node.items.nodes[] | select(.content.number == '"$pr_number"') | .content.number' 2>/dev/null
}

# Fetch the project ID for the 'ASSEMBLE' project
PROJECT_ID=$(get_project_id)

if [ -z "$PROJECT_ID" ]; then
  echo "Project '$PROJECT_NAME' not found in organization '$ORG'."
  exit 1
fi

echo "Using Project ID: $PROJECT_ID"

# Fetch all repositories in the organization
REPOS=$(gh repo list "$ORG" --limit 1000 --json nameWithOwner -q '.[].nameWithOwner')

for REPO in $REPOS; do
  echo "Processing repository: $REPO"

  # Fetch all open PRs in the repository
  PULL_REQUESTS=$(gh pr list --repo "$REPO" --state open --json number -q '.[].number')

  for PR_NUMBER in $PULL_REQUESTS; do
    echo "  Processing PR #$PR_NUMBER"

    # Check if the PR is already in the project
    EXISTING_PR=$(is_pr_in_project "$PR_NUMBER")
    if [ "$EXISTING_PR" == "$PR_NUMBER" ]; then
      echo "    PR #$PR_NUMBER is already in the project. Skipping."
      continue
    fi

    # Fetch the Pull Request node ID
    PR_NODE_ID=$(gh api graphql -f query='
      query($owner: String!, $repo: String!, $prNumber: Int!) {
        repository(owner: $owner, name: $repo) {
          pullRequest(number: $prNumber) {
            id
          }
        }
      }
    ' -f owner="$(echo "$REPO" | cut -d'/' -f1)" \
       -f repo="$(echo "$REPO" | cut -d'/' -f2)" \
       -f prNumber="$PR_NUMBER" \
       --jq ".data.repository.pullRequest.id")

    if [ -z "$PR_NODE_ID" ]; then
      echo "    Could not fetch node ID for PR #$PR_NUMBER. Skipping."
      continue
    fi

    # Add the PR to the project
    RESPONSE=$(gh api graphql -X POST -f query='
      mutation($projectId: ID!, $contentId: ID!) {
        addProjectV2ItemById(input: {projectId: $projectId, contentId: $contentId}) {
          item {
            id
          }
        }
      }
    ' -f projectId="$PROJECT_ID" \
       -f contentId="$PR_NODE_ID" 2>&1) || {
         echo "    Failed to add PR #$PR_NUMBER to project. Response:"
         echo "$RESPONSE"
         continue
       }

    echo "    Added PR #$PR_NUMBER to project '$PROJECT_NAME'."
    
    # Optional: Sleep to respect rate limits
    sleep 0.5  # Sleeps for half a second
  done
done

echo "All PRs have been processed."