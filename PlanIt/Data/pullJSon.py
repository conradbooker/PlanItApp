import icsJSon
import json

def returnJSon(URL):
    result = [icsJSon.fromWeb(URL)]
    return(json.dumps(result, indent=3, separators=(", ", ": ")))

