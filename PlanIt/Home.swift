//
//  Home.swift
//  PlanIt
//
//  Created by Conrad on 12/23/22.
//

import SwiftUI

struct Home: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "course", ascending: true)]) private var allAssignments: FetchedResults<Assignment>
    
    var assignmentSpacing: CGFloat = 5
    
    @State private var currentDate: Date = Date.now
    @State private var selectedDate: Date = Date.now
    let calendar = Calendar.current

    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    
    @State var checkInProgress: Int = 0
    @State var checkToDo: Int = 0
    @State var checkFinished: Int = 0
    
    @State private var totalHours: Int = 0
    @State private var totalMinutes: Int = 0

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
                                if assign.datePlanned!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                    if assign.status == "In Progress" {
                                        AssignmentViewNew(assignment: assign)
                                            .environment(\.managedObjectContext, persistedContainer.viewContext)
                                            .onAppear {
                                                checkInProgress += 1
                                                if !assign.isFinished {
                                                    totalMinutes += Int(assign.minuteStop)
                                                    totalHours += Int(assign.hourStop)
                                                }
                                            }
                                            .onDisappear {
                                                checkInProgress -= 1
                                                if !assign.isFinished {
                                                    totalMinutes -= Int(assign.minuteStop)
                                                    totalHours -= Int(assign.hourStop)
                                                }
                                            }
//                                            .onChange(of: assign.minuteStop) { _ in
//                                                totalMinutes -=
//                                            }
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
                                if assign.datePlanned!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                    if assign.status == "To Do" {
                                        AssignmentViewNew(assignment: assign)
                                            .environment(\.managedObjectContext, persistedContainer.viewContext)
                                            .onAppear {
                                                checkToDo += 1
                                                if !assign.isFinished {
                                                    totalMinutes += Int(assign.minuteStop)
                                                    totalHours += Int(assign.hourStop)
                                                }
                                            }
                                            .onDisappear {
                                                checkToDo -= 1
                                                if !assign.isFinished {
                                                    totalMinutes -= Int(assign.minuteStop)
                                                    totalHours -= Int(assign.hourStop)
                                                }
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
                                if assign.datePlanned!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                    if assign.status == "Finished!" {
                                        AssignmentViewNew(assignment: assign)
                                            .environment(\.managedObjectContext, persistedContainer.viewContext)
                                            .onAppear {
                                                checkFinished += 1
                                                if !assign.isFinished {
                                                    totalMinutes += Int(assign.minuteStop)
                                                    totalHours += Int(assign.hourStop)
                                                }
                                            }
                                            .onDisappear {
                                                checkFinished -= 1
                                                if !assign.isFinished {
                                                    totalMinutes -= Int(assign.minuteStop)
                                                    totalHours -= Int(assign.hourStop)
                                                }
                                            }
                                    }
                                }
                            }
                            Group {
                                if checkFinished == 0 && checkToDo == 0 && checkInProgress == 0 {
                                    HStack {
                                        Text("Nothing planned tomorrow :)")
                                            .padding([.top, .leading])
                                        Spacer()
                                    }
                                }
                                FormattedTime(hourStop: totalHours, minuteStop: totalMinutes)
                            }
                            Spacer().frame(height: 100)
                        }
                    }
                    VStack {
                        Spacer().frame(height:geometry.size.height-150)
                        DateSelector(selectedDate: $selectedDate)
                            .frame(width: UIScreen.screenWidth - 10)
                    }
                }
                .navigationTitle("Welcome back, Cunt!")
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

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        Home().environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
