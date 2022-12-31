from urllib.request import Request, urlopen
from io import StringIO

# jicson.py by CalyFactory (git: https://github.com/CalyFactory/python-jicson)
# modified by Conrad Booker


class StreamObject:

    def __init__(self, type, url = None, auth = None, filePath = None, text = None):
        self.type = type
        self.url = url
        self.auth = auth
        self.filePath = filePath
        self.text = text

        if self.type == "web":
            request = Request(url)
            request.add_header("Authorization", "Basic "+ str(auth))
            self.response = urlopen(request)
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
        
        if separator == -1 and line[0] != " " and line[1] != " ":
            continue
        # if the separator is not found or the line space 0 contains a space
        
        if line[0] != " " and line[1] != " ":
            key = line[:separator]
            value = line[separator+1:]
        else:
            value = line[1:]


        if key == "BEGIN":
            if value not in json:
                json[value] = []
            json[value].append(parseChild({}, fileObject))
        elif key == "END":
            return json
        elif line[0] == " " or line[1] == " ":
            #'add extra summary + extra description'

            if json.get("DESCRIPTION") == None and json.get("SUMMARY") != None:
                if json.get("EXTRASUMMARY") == None:
                    json["EXTRASUMMARY"] = ""
                    json["EXTRASUMMARY"] += value
            else:
                if json.get("EXTRADESCRIPTION") == None:
                    json["EXTRADESCRIPTION"] = ""
                    json["EXTRADESCRIPTION"] += value
                else:
                    json["EXTRADESCRIPTION"] += value
            # if json.get("DESCRIPTION") == None:
            #     json["DESCRIPTION"] = ""

        else:
            json[key] = value

            if json.get("DESCRIPTION") == None:
                json["DESCRIPTION"] = ""
                if json.get("EXTRASUMMARY") == None:
                    json["EXTRASUMMARY"] = ""
                if json.get("EXTRADESCRIPTION") == None:
                    json["EXTRADESCRIPTION"] = ""

