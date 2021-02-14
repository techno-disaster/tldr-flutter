import json
from os import path
import json
import requests


def get_dict():
    r = requests.get(url="https://tldr.sh/assets/")
    data = json.loads(r.text)
    commands = {}
    for command in range(len(data["commands"])):
        commands[data["commands"][command]["name"]
                 ] = data["commands"][command]["platform"][0]
    return commands


def update_commands_file():
    """Run scheduled job to update commands file."""
    _ = get_dict()
    data = json.dumps(_)
    try:
        file = open('static/commands.txt', 'wt')
        file.write(data)
        file.close()
        print("Commands added")

    except:
        print
        print("Unable to write to file")


if __name__ == '__main__':
    update_commands_file()
