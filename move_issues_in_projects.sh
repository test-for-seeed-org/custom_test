#!/bin/bash
# Replace 'your-organization' with your actual organization name
ORG="Seeed-Studio"

# Fetch all open issues from the repository
issues=$(gh issue list -R $ORG/Temp_Hmi_Suli --state open --json number --jq .[].number)

# Loop through each issue and apply the "Unassigned" label
for issue in $issues; do
    gh issue edit $issue -R $ORG/Temp_Hmi_Suli --add-label "Unassigned"
done