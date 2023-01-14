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
            List(assignments, id: \.self) { assign in
                Text("\(assign.course) || \(assign.title)")
                Text("\(assign.description)")
                    .font(.system(size: 8))
                Text(assign.dueDate, style: .date)
            }
        }
    }
}

struct Planner_Previews: PreviewProvider {
    static var previews: some View {
        Planner()
    }
}
