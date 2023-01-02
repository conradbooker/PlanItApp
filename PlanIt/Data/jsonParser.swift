//
//  jsonParser.swift
//  PlanIt
//
//  Created by Conrad on 12/30/22.
//

import Foundation
import SwiftUI

struct AssignmentOnline: Decodable {
    
    var VERSION: String
    var METHOD: String
    var PRODID: String
    var CALSCALE: String
    var VEVENT: [IndividualOnlineAssignmets]
    
//    var image: Image {
//        Image(name)
//    }
        
}

struct ICSCal: Decodable {
    var VCALENDAR: [AssignmentOnline]
}

struct IndividualOnlineAssignmets: Decodable {
    var UID: String
    var DESCRIPTION: String
    var EXTRASUMMARY: String
    var EXTRADESCRIPTION: String
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

var onlineAssignmentData: [ICSCal] = load("data (5).json")
//var onlineAssignmentData: [ICSCal] = runPythonICSJSon("https://trinityschoolnyc.myschoolapp.com/podium/feed/iCal.aspx?z=HdbCT3ZaWBaxtYaG0jy3COOOHSIw9SwPejVt1ZiRL0e%2f1LkExSAan453LoSYfB4QMIeAjRyRcFPyvvRbCsQ7QA%3d%3d")

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
