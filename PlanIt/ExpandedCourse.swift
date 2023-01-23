//
//  ExpandedCourse.swift
//  PlanIt
//
//  Created by Conrad on 1/20/23.
//

import SwiftUI

struct ExpandedCourse: View {
    var assignment: Assignment
    var body: some View {
        NavigationView {
            VStack {
                Text("Hello, World!")
            }
                .navigationTitle("Focus Mode")
        }
    }
}

struct ExpandedCourse_Previews: PreviewProvider {
    @Environment(\.managedObjectContext) static var viewContext
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        
        ExpandedCourse(assignment: Assignment(context: viewContext))
            .environment(\.managedObjectContext, persistedContainer.viewContext)
//            .previewLayout(.fixed(width: 400, height: 250))
    }
}
