//
//  ExternalSource.swift
//  PlanIt
//
//  Created by Conrad on 12/29/22.
//

import SwiftUI

struct ExternalSource: View {
    
    @State private var sourceURL: String = ""
    
/*
 BEGIN:VEVENT --- start
 UID:683747ac-fae0-418b-a77e-fd1b0de61e9c --- uuid
 DTSTART;VALUE=DATE:20221213 --- completion date
 DTEND;VALUE=DATE:20221214 --- due date
 DTSTAMP:20221229T213146 --- current date
 SUMMARY:INTEGRATED MATH 3 - C: HW #2 --- Class, section, assignment title
 DESCRIPTION:9, 10, 11, 12, 13 --- description (can be multiple lines)
 STATUS:CONFIRMED
 CLASS:PUBLIC
 PRIORITY:3
 CATEGORIES:podium,events
 END:VEVENT
*/
    
    var body: some View {
        TextField("Enter URL", text: $sourceURL)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
    }
}

struct ExternalSource_Previews: PreviewProvider {
    static var previews: some View {
        ExternalSource()
    }
}
