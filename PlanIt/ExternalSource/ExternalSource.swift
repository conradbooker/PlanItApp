//
//  ExternalSource.swift
//  PlanIt
//
//  Created by Conrad on 12/29/22.
//

import SwiftUI

struct ExternalSource: View {
    @State var state: String = "Step1"
    @State var courses: [courseMatch] = findCourses()
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    @Binding var isPresented: Bool
    
    var body: some View {
        switch state {
        case "Step1": withAnimation(.easeIn) { Step1(state: $state, courses: $courses, isPresented: $isPresented).environment(\.managedObjectContext, persistedContainer.viewContext)
        }
        case "Step2": withAnimation(.easeIn) { Step2(state: $state, courses: $courses).environment(\.managedObjectContext, persistedContainer.viewContext)
        }
        case "Step3": withAnimation(.easeIn) { Step3(courses: courses, state: $state, isPresented: $isPresented).environment(\.managedObjectContext, persistedContainer.viewContext)
        }
        default: withAnimation(.easeIn) { Step1(state: $state, courses: $courses, isPresented: $isPresented).environment(\.managedObjectContext, persistedContainer.viewContext)
        }
        }
    }
}

struct ExternalSource_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        ExternalSource(isPresented: .constant(true)).environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
