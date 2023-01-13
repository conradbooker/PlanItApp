//
//  jsonParser.swift
//  PlanIt
//
//  Created by Conrad on 12/30/22.
//

import Foundation
import SwiftUI
import PythonSupport

var defaultJSon = """
[
   {
      "VCALENDAR": [
         {
            "VERSION": "2.0",
            "DESCRIPTION": "",
            "EXTRASUMMARY": "",
            "EXTRADESCRIPTION": "",
            "METHOD": "PUBLISH",
            "PRODID": "",
            "CALSCALE": "GREGORIAN",
            "VTIMEZONE": [
               {
                  "TZID": "America/Colorado",
                  "EXTRADESCRIPTION": "",
                  "X-LIC-LOCATION": "America/Colorado",
                  "DAYLIGHT": [
                     {
                        "TZOFFSETFROM": "-0500",
                        "DESCRIPTION": "",
                        "EXTRASUMMARY": "",
                        "EXTRADESCRIPTION": "",
                        "TZOFFSETTO": "-0400",
                        "TZNAME": "Eastern Daylight Time",
                        "DTSTART": "20220313T020000",
                        "RRULE": "FREQ=YEARLY;INTERVAL=1;BYMONTH=3;BYDAY=2SU"
                     }
                  ]
               }
            ],
            "VEVENT": [
               {
                  "UID": "424a4b1e-8b17-11ed-a1eb-0242ac120002",
                  "DESCRIPTION": "description",
                  "EXTRASUMMARY": "",
                  "EXTRADESCRIPTION": "",
                  "DTSTART": "VALUE=DATE:20220908",
                  "DTEND": "VALUE=DATE:20220909",
                  "DTSTAMP": "20221231T152802",
                  "SUMMARY": "Error: Assignments did not load properly. Seek [help] for help",
                  "STATUS": "CONFIRMED",
                  "CLASS": "PUBLIC",
                  "PRIORITY": "3",
                  "CATEGORIES": "podium,events"
               }
            ]
         }
      ]
   }
]

"""

struct AssignmentOnline: Decodable, Hashable, Identifiable {
    
    var id: String {
        self.VERSION
    }
    var VERSION: String
    var METHOD: String
    var PRODID: String
    var CALSCALE: String
    var VEVENT: [IndividualOnlineAssignmets]
    
//    var image: Image {
//        Image(name)
//    }
        
}

struct ICSCal: Decodable, Hashable, Identifiable {
    var VCALENDAR: [AssignmentOnline]
    var id: [AssignmentOnline] {
        self.VCALENDAR
    }
}

struct IndividualOnlineAssignmets: Decodable, Hashable, Identifiable {
    
    var id: String {
        self.SUMMARY + self.DTEND
    }

    var UID: String
    var DESCRIPTION: String
    var DTSTART: String
    var DTEND: String
    var DTSTAMP: String
    var SUMMARY: String
    var STATUS: String
    var CLASS: String
    var PRIORITY: String
    var CATEGORIES: String
}

// To be accessible by AssignmentOnline[0].IndividualAssignmets
/*
 for IndividualAssignment in AssignmentOnline[0].IndividualAssignmets {
  return IndividualAssignment.title
 }
 
 1. list the assignments to check if everythings is correct
 2. make new coredata model entity for the assignmemts that were online
 
 
 TODO: make the structs + objects
 then python - swiftcoding
 then format the data to make sure everythings is correct
 */

func returnString() -> String {
    PythonSupport.initialize()
    @AppStorage("pyJSonData") var pyJSonData: String = ""
    @AppStorage("sourceURL") var sourceURL: String = ""
    var pyString = ""
    
    // in the future this will load on saving the data and on update, so here, in the future, loading from string should be from the @AppStorage("pyJSonData")
    if sourceURL.contains("iCal") || sourceURL.contains("ical") || sourceURL.contains(".ics") {
        pyString = String(runPythonICSJSon(sourceURL)) ?? defaultJSon
    } else {
        pyString = defaultJSon
    }
    
    if !pyString.contains("VEVENT") || pyString == "{}" || pyString == """
    [
       {}
    ]
    """ {
        pyString = defaultJSon
    }
    
    pyJSonData = pyString
    
    return(pyString)
}

//var onlineAssignmentData: [ICSCal] = load("data.json")

var onlineAssignmentData: [ICSCal]  = returnString().decodeJson([ICSCal].self)

//let menuItems = try! JSONDecoder().decode([ICSCal].self, from: jsonData)
//let

//@AppStorage("pyJSonData") var pyJSonData: String = ""
//
//func loadJSon() -> String {
//    AppStorage("pyJSonData") var pyJSonData: String = ""
//}

extension String {
  func decodeJson <T: Decodable> (_ type : T.Type ,
  dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
  keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        
     let jsonData = self.data(using: .utf8)!
       
      do {
         let decoder = JSONDecoder()
         decoder.dateDecodingStrategy = dateDecodingStrategy
         decoder.keyDecodingStrategy = keyDecodingStrategy
   
         let result = try decoder.decode(type, from: jsonData)
         return result
      }
      catch {
          fatalError("err:\(error)")
      }
   }
}



func loadJSonURL() {
    onlineAssignmentData = returnString().decodeJson([ICSCal].self)
}

func load<T: Decodable>(_ filename: String) -> T {
    
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
