//
//  Planner.swift
//  PlanIt
//
//  Created by Conrad on 12/24/22.
//

import SwiftUI

struct Planner: View {
    
    let assignments = onlineAssignmentData[0].VCALENDAR[0].VEVENT
    
    var body: some View {
        VStack {
            List(assignments, id: \.SUMMARY) { assign in
                Text(assign.SUMMARY)
            }
        }
    }
}

struct Planner_Previews: PreviewProvider {
    static var previews: some View {
        Planner()
    }
}
