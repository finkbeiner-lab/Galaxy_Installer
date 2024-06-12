import argparse
import time
from bioblend.galaxy import GalaxyInstance
import os
import sys

# Import common logging functions
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from common import log_info, log_error

def create_admin_user(galaxy_instance, email, password, username):
    response = galaxy_instance.users.create_remote_user(email=email)
    if 'id' in response:
        log_info(f"Admin user {email} created successfully.")
    else:
        log_error(f"Error creating admin user: {response}")
        sys.exit(1)

def generate_api_key(galaxy_instance, user_email):
    users = galaxy_instance.users.get_users(f_email=user_email)
    if users:
        user_id = users[0]['id']
        api_key = galaxy_instance.users.create_user_apikey(user_id)
        log_info(f"API key for {user_email}: {api_key}")
        return api_key
    else:
        log_error(f"User {user_email} not found.")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description='Create a Galaxy admin user and generate an API key.')
    parser.add_argument('galaxy_url', type=str, help='URL of the Galaxy instance')
    parser.add_argument('admin_email', type=str, help='Email of the admin user')
    parser.add_argument('admin_password', type=str, help='Password for the admin user')
    parser.add_argument('admin_username', type=str, help='Username for the admin user')
    args = parser.parse_args()

    # Create Galaxy instance with admin privileges
    admin_gi = GalaxyInstance(url=args.galaxy_url, key='admin_api_key')

    # Create the admin user
    create_admin_user(admin_gi, args.admin_email, args.admin_password, args.admin_username)

    # Wait a bit to ensure the user is created
    time.sleep(5)

    # Generate API key for the admin user
    admin_api_key = generate_api_key(admin_gi, args.admin_email)

    # Print the admin API key for use
    if admin_api_key:
        print(admin_api_key)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
