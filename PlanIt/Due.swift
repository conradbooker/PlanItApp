//
//  Due.swift
//  PlanIt
//
//  Created by Conrad on 12/24/22.
//

import SwiftUI

struct Due: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
    var assignmentSpacing: CGFloat = 5
    
    @State private var currentDate: Date = Date.now
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    let calendar = Calendar.current

    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    
    private func findHeight(_ text: String) -> CGFloat {
        if Double(text.count) / 45 < 1.5 {
            return 135
        }
        return CGFloat((text.count / 45) * 17 + 140)
    }

    @State var checkInProgress: Int = 0
    @State var checkToDo: Int = 0
    @State var checkFinished: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    Color("cDarkGray")
                        .ignoresSafeArea()
                    ScrollView {
                        VStack {
                            if checkInProgress == 0 && checkToDo == 0 && checkFinished != 0 {
                                HStack {
                                    Text("you finished everything for today!!!")
                                        .padding([.top, .leading])
                                    Spacer()
                                }
                            }
                            
                            // MARK: In Progress
                            if checkInProgress != 0 {
                                HStack {
                                    Text("in progress")
                                        .padding([.top, .leading])
                                    Spacer()
                                }
                            }
                            ForEach(allAssignments) { assign in
                                if assign.dueDate!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                    if assign.status == "In Progress" {
                                        AssignmentViewNew(assignment: assign)
                                            .frame(width: geometry.size.width, height: findHeight(assign.title ?? "") + assignmentSpacing)
                                            .environment(\.managedObjectContext, persistedContainer.viewContext)
                                            .onAppear {
                                                checkInProgress += 1
                                            }
                                            .onDisappear {
                                                checkInProgress -= 1
                                            }
                                    }
                                }
                            }
                            
                            // MARK: To Do
                            if checkToDo != 0 {
                                HStack {
                                    Text("to do")
                                        .padding([.top, .leading])
                                    Spacer()
                                }
                            }
                            
                            ForEach(allAssignments) { assign in
                                if assign.dueDate!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                    if assign.status == "To Do" {
                                        AssignmentViewNew(assignment: assign).frame(width: geometry.size.width, height: findHeight(assign.title ?? "") + assignmentSpacing).environment(\.managedObjectContext, persistedContainer.viewContext)
                                            .onAppear {
                                                checkToDo += 1
                                            }
                                            .onDisappear {
                                                checkToDo -= 1
                                            }
                                    }
                                }
                            }
                            
                            // MARK: Completed
                            if checkFinished != 0 {
                                HStack {
                                    Text("completed things!")
                                        .padding([.top, .leading])
                                    Spacer()
                                }
                            }
                            
                            ForEach(allAssignments) { assign in
                                if assign.dueDate!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                    if assign.status == "Finished!" {
                                        AssignmentViewNew(assignment: assign).frame(width: geometry.size.width, height: findHeight(assign.title ?? "") + assignmentSpacing).environment(\.managedObjectContext, persistedContainer.viewContext)
                                            .onAppear {
                                                checkFinished += 1
                                            }
                                            .onDisappear {
                                                checkFinished -= 1
                                            }
                                    }
                                }
                            }
                            if checkFinished == 0 && checkToDo == 0 && checkInProgress == 0 {
                                HStack {
                                    Text("Nothing due tomorrow :)")
                                        .padding([.top, .leading])
                                    Spacer()
                                }
                            }
                            Spacer().frame(height: 100)
                        }
                    }
                    VStack {
                        Spacer().frame(height:geometry.size.height-150)
                        DateSelector(selectedDate: $selectedDate)
                    }
                }
                .navigationTitle("Due")
            }
        }
    }
    
    func add() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
    }
    func subtract() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
    }
}


struct Due_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        Due().environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
