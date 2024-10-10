#!/bin/bash

# List all repositories and iterate through them
gh repo list Seeed-Studio --limit 1000 --json nameWithOwner -q ".[].nameWithOwner" | while read repo; do
  echo "Fetching workflows for repository: $repo"
  # List all workflows for each repository
  gh api repos/$repo/actions/workflows --paginate --jq '.workflows[] | {name: .name, id: .id, state: .state}' 
done