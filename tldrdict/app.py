import json
from os import path

import requests
from flask import Flask

app = Flask(__name__, static_url_path="/static")


@app.route('/')
def commands_file():
    if not path.exists("static/commands.txt"):
        update_commands_file()
    return app.send_static_file('commands.txt')


def get_dict():
    r = requests.get(url="https://tldr.sh/assets/")
    data = json.loads(r.text)
    commands = {}
    for command in range(len(data["commands"])):
        commands[data["commands"][command]["name"]] = data["commands"][command]["platform"][0]
    return commands


@app.cli.command()
def update_commands_file():
    """Run scheduled job to update commands file."""
    data = get_dict()
    try:
        file = open('static/commands.txt', 'wt')
        file.write(str(data))
        file.close()
        print("Commands added")

    except:
        print("Unable to write to file")


if __name__ == '__main__':
    app.run()
