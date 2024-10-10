#!/bin/bash

# Set variables
GITHUB_USER="Seeed-Studio"  # Organization name
REPO="PN532"                # Specific repository name

echo "Processing repository: $GITHUB_USER/$REPO"

# Fetch all open issues from the repository
gh issue list --repo $GITHUB_USER/$REPO --limit 1000 --json number --jq '.[].number' | while read issue_number
do
    # Remove the 'UAY' label from the issue, if it exists
    gh issue edit $issue_number --repo $GITHUB_USER/$REPO --remove-label "UAY"
    echo "Removed label 'UAY' from issue #$issue_number in $GITHUB_USER/$REPO."

    # Add the 'UAY' label back to the issue
    gh issue edit $issue_number --repo $GITHUB_USER/$REPO --add-label "UAY"
    echo "Added label 'UAY' back to issue #$issue_number in $GITHUB_USER/$REPO."
done

echo "Labels 'UAY' have been removed and re-added to all issues in repository $GITHUB_USER/$REPO."