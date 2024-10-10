#!/bin/bash

# Set variables
GITHUB_USER="MatthewJeffson"  # Replace with your GitHub username or organization name

# Loop through all repositories
gh repo list $GITHUB_USER --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner' | while read repo
do
  # Extract only the repository name from the full nameWithOwner
  repo_name="${repo##*/}"

  # Skip processing for the wiki-documents repository
  if [ "$repo_name" = "wiki-documents" ]; then
    echo "Skipping repository: $repo"
    continue
  fi

  echo "Processing repository: $repo"

  # Check if the 'NAY' label exists, if not, create it
  if ! gh label view NAY --repo $repo &> /dev/null; then
    gh label create NAY --repo $repo --color "FF5733" --description "General label NAY"
    echo "Label 'NAY' created in $repo."
  fi

  # Check if the repo-specific label exists, if not, create it
  if ! gh label view "$repo_name" --repo $repo &> /dev/null; then
    gh label create "$repo_name" --repo $repo --color "0E8A16" --description "Label specific for $repo_name"
    echo "Label '$repo_name' created in $repo."
  fi

  # Fetch all open issues from the repository and add both labels
  gh issue list --repo $repo --limit 1000 --json number --jq '.[].number' | while read issue_number
  do
    gh issue edit $issue_number --repo $repo --add-label "NAY" --add-label "$repo_name"
    echo "Added labels 'NAY' and '$repo_name' to issue #$issue_number in $repo."
  done
done

echo "Labels have been added to all issues across all repositories, except for wiki-documents."