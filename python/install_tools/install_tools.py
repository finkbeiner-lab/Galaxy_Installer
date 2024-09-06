import argparse
from bioblend.galaxy import GalaxyInstance

# Function to install a tool repository from the Tool Shed using its .shed.yml metadata
def install_repository(galaxy_instance, tool_shed_url, repository_name, repository_owner):
    print(f"Installing repository {repository_name} from owner {repository_owner}...")
    try:
        response = galaxy_instance.toolshed.install_repository_revision(
            tool_shed_url=tool_shed_url,
            name=repository_name,
            owner=repository_owner,
            changeset_revision='default',
            install_tool_dependencies=True,
            install_repository_dependencies=True,
            tool_panel_section_id=None,
        )
        print(f"Repository installed successfully: {response}")
    except Exception as e:
        print(f"Failed to install repository {repository_name}: {str(e)}")

# Function to parse command-line arguments
def parse_arguments():
    parser = argparse.ArgumentParser(description="Install tools into Galaxy from a Tool Shed repository using BioBlend.")
    parser.add_argument("--api_key", required=True, help="The API key for the Galaxy admin user.")
    parser.add_argument("--galaxy_url", required=True, help="The URL of the Galaxy instance.")
    parser.add_argument("--repository_name", required=True, help="The name of the Tool Shed repository to install.")
    parser.add_argument("--repository_owner", required=True, help="The owner of the Tool Shed repository.")
    parser.add_argument("--tool_shed_url", default="https://toolshed.g2.bx.psu.edu/", help="The URL of the Tool Shed (default: https://toolshed.g2.bx.psu.edu/).")
    return parser.parse_args()

# Main function
def main():
    args = parse_arguments()

    # Connect to the Galaxy instance
    galaxy_instance = GalaxyInstance(url=args.galaxy_url, key=args.api_key)

    # Install the repository using the correct name and owner
    install_repository(
        galaxy_instance,
        args.tool_shed_url,
        args.repository_name,
        args.repository_owner
    )

if __name__ == "__main__":
    main()

