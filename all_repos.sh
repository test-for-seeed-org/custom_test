# Replace 'your-organization' with your actual organization name
ORG="Seeed-Studio"

# Get a list of all repository names in the organization
repos=$(gh repo list $ORG --limit 1000 --json name --jq .[].name)

# Loop through each repository and list issues
for repo in $repos; do
    echo "Issues in $repo:"
    gh issue list -R $ORG/$repo --json number,title,labels --jq '.[] | {number, title, labels: [.labels[].name]}'
    echo ""  # Adds a newline for better readability
done

