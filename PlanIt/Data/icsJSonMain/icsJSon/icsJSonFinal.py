import icsJSon
import json 
# import pyperclip
# import requests


def returnicsJSon(path, type = "web"):

    if path == None:
        return "\nError: path must be specified.\n"

    if type == "web":
        result = [icsJSon.fromWeb(path)]

    elif type == "file":
        result = [icsJSon.fromFile(path)]

    else:
        result = [icsJSon.fromText(path)]

    return(json.dumps(result, indent=3, separators=(", ", ": ")))
