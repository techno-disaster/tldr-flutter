"""
Downloads folders from github repo
Requires PyGithub
pip install PyGithub
"""

import os
import sys
import base64
import shutil
import getopt
from github import Github
from github import GithubException

def get_sha_for_tag(repository, tag):
    """
    Returns a commit PyGithub object for the specified repository and tag.
    """
    branches = repository.get_branches()
    matched_branches = [match for match in branches if match.name == tag]
    if matched_branches:
        return matched_branches[0].commit.sha

    tags = repository.get_tags()
    matched_tags = [match for match in tags if match.name == tag]
    if not matched_tags:
        raise ValueError('No Tag or Branch exists with that name')
    return matched_tags[0].commit.sha


def download_directory(repository, sha, server_path):
    """
    Download all contents at server_path with commit tag sha in
    the repository.
    """
    if os.path.exists(server_path):
        shutil.rmtree(server_path)

    os.makedirs(server_path)
    print('here')
    contents = repository.get_contents(server_path, ref=sha)
    print('here23')
    for content in contents:
        print("Processing %s" % content.path)
        if content.type == 'dir':
            os.makedirs(content.path)
            download_directory(repository, sha, content.path)
        else:
            try:
                path = content.path
                file_content = repository.get_contents(path, ref=sha)
                file_data = base64.b64decode(file_content.content)
                file_out = open(content.path, "wb+")
                file_out.write(file_data)
                file_out.close()
            except (GithubException, IOError) as exc:
                print('Error processing %s: %s', content.path, exc)

def usage():
    """
    Prints the usage command lines
    """
    print("usage: gh-download --token=token --org=org --repo=repo --branch=branch --folder=folder")

def main(argv):
    """
    Main function block
    """
    try:
        opts, args = getopt.getopt(argv, "t:o:r:b:f:", ["token=", "org=", "repo=", "branch=", "folder="])
    except getopt.GetoptError as err:
        print(str(err))
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-t", "--token"):
            token = arg
        elif opt in ("-o", "--org"):
            org = arg
        elif opt in ("-r", "--repo"):
            repo = arg
        elif opt in ("-b", "--branch"):
            branch = arg
        elif opt in ("-f", "--folder"):
            folder = arg

    github = Github(token)
    organization = github.get_organization(org)
    repository = organization.get_repo(repo)
    sha = get_sha_for_tag(repository, branch)
    download_directory(repository, sha, folder)

if __name__ == "__main__":
    """
    Entry point
    """
    main(sys.argv[1:])