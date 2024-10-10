#!/bin/bash

# Set variables
GITHUB_USER="Seeed-Studio"  # Organization name

# Loop through all repositories
gh repo list $GITHUB_USER --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner' | while read repo
do
  echo "Processing repository: $repo"

  # Extract only the repository name from the full nameWithOwner
  repo_name="${repo##*/}"

    # Bypass the repository "wiki-documents"
  if [ "$repo_name" = "wiki-documents" ]; then
    echo "Skipping repository: $repo_name"
    continue
  fi

  # Check if the fixed label 'UAY' exists, if not, create it
  if ! gh label view UAY --repo $repo &> /dev/null; then
    gh label create UAY --repo $repo --color "FFFFFF" --description "Unassigned yet"
    echo "Label 'UAY' created in $repo."
  fi

  # Check if the repo-specific label exists, if not, create it
  if ! gh label view "$repo_name" --repo $repo &> /dev/null; then
    gh label create "$repo_name" --repo $repo --color "8DC21F" --description "Label for $repo_name"
    echo "Label '$repo_name' created in $repo."
  fi

  # Fetch all open issues from the repository and add both labels
  gh issue list --repo $repo --limit 1000 --json number --jq '.[].number' | while read issue_number
  do
    gh issue edit $issue_number --repo $repo --add-label "UAY" --add-label "$repo_name"
    echo "Added labels 'UAY' and '$repo_name' to issue #$issue_number in $repo."
  done
done

echo "Labels have been added to all issues across all repositories."