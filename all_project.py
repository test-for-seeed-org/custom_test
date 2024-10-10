import requests

def list_github_projects(org, token):
    """
    Lists all GitHub Projects in a specified organization.

    Parameters:
    - org (str): Name of the GitHub organization.
    - token (str): GitHub personal access token with 'repo' and 'read:org' permissions.

    Outputs:
    - Prints each project's name and its URL.
    """
    # GitHub API endpoint for fetching organization projects
    url = f"https://api.github.com/orgs/{org}/projects"
    
    # Headers required for the API request
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.inertia-preview+json'  # This custom media type is necessary for projects
    }
    
    # Make the GET request to the GitHub API
    response = requests.get(url, headers=headers)
    
    # Check if the request was successful
    if response.status_code == 200:
        projects = response.json()
        if projects:
            for project in projects:
                print(f"Project Name: {project['name']}, Project URL: {project['html_url']}")
        else:
            print("No projects found in this organization.")
    else:
        print(f"Failed to fetch projects: {response.status_code} - {response.text}")

# Replace 'your_organization' with the actual GitHub organization name
# Replace 'your_token' with a valid GitHub personal access token
list_github_projects('Seeed-Studio', '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')