//
//  Planner.swift
//  PlanIt
//
//  Created by Conrad on 12/24/22.
//

import SwiftUI

struct Planner: View {
    
    let assignments = onlineAssignmentData[0].VCALENDAR[0].VEVENT
    @State private var startDate = Date()
    @State private var stopDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    
    func add() {
        startDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
        stopDate = Calendar.current.date(byAdding: .day, value: 7, to: stopDate)!
    }
    
    func subtract() {
        startDate = Calendar.current.date(byAdding: .day, value: -7, to: startDate)!
        stopDate = Calendar.current.date(byAdding: .day, value: -7, to: stopDate)!
    }
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
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
