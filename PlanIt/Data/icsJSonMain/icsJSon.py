from urllib.request import Request, urlopen
from io import StringIO
import ssl
import certifi
import json

# jicson.py by CalyFactory (git: https://github.com/CalyFactory/python-jicson)
# modified by Conrad Booker


class StreamObject:

    def __init__(self, type, url = None, auth = None, filePath = None, text = None):
        context = ssl.create_default_context(cafile=certifi.where())

        self.type = type
        self.url = url
        self.auth = auth
        self.filePath = filePath
        self.text = text

        if self.type == "web":
            request = Request(url)
            request.add_header("Authorization", "Basic "+ str(auth))
            self.response = urlopen(request,context=context)
        elif self.type == "file":
            self.file = open(filePath)
        elif self.type == "text":
            self.buf = StringIO(text)
        else:
            self.buf = StringIO(text)
    
    def readline(self):
        if self.type == "web":
            line = (self.response.readline().decode('utf-8'))
        elif self.type == "file":
            line = (self.file.readline())
            # the self.file.readline
        elif self.type == "text":
            line = (self.buf.readline())
        else:
            line = (self.buf.readline())
        
        line = line.rstrip('\n')
        return line

def fromWeb(icsFileUrl, auth = None):
    streamObject = StreamObject(
        type = "web",
        url = icsFileUrl,
        auth = auth
    )
    return (parseChild({}, streamObject))

def fromFile(icsFilePath):
    streamObject = StreamObject(
        type = "file",
        filePath = icsFilePath
    )
    return (parseChild({}, streamObject))

def fromText(icsFileText):
    streamObject = StreamObject(
        type = "text",
        text = icsFileText
    )
    return (parseChild({}, streamObject))

def parseChild(json, fileObject):
   
    while True:
        line = fileObject.readline()

        if not line:
            return json

        line = line.rstrip('\n\r')

        separator = line.find(":")
        separatorSemi = line.find(";")
        
        
        if separator == -1 and line[0] != " " and line[1] != " ":
            continue
        # if the separator is not found or the line space 0 contains a space
        
        if separatorSemi == 7 or separatorSemi == 5:
            if line[0] != " " and line[1] != " ":
                key = line[:separatorSemi]
                value = line[separatorSemi+1:]
            else:
                value = line[1:]
        else:
            if line[0] != " " and line[1] != " ":
                key = line[:separator]
                value = line[separator+1:]
            else:
                value = line[1:]

        line = line.replace("&amp;","")


        if key == "BEGIN":
            if value not in json:
                json[value] = []
            json[value].append(parseChild({}, fileObject))
        elif key == "END":
            return json
        elif line[0] == " " or line[1] == " ":

            if json.get("DESCRIPTION") == None and json.get("SUMMARY") != None:
                json["SUMMARY"] += value
            else:
                json["DESCRIPTION"] += value

        else:
            json[key] = value

            if json.get("STATUS") != None and json.get("DESCRIPTION") == None:
                json["DESCRIPTION"] = "No description."

def returnicsJSon(path, type = "web"):

    if path == None:
        return "\nError: path must be specified.\n"

    if type == "web":
        result = [fromWeb(path)]

    elif type == "file":
        result = [fromFile(path)]

    else:
        result = [fromText(path)]

    return(json.dumps(result, indent=3, separators=(", ", ": ")))
