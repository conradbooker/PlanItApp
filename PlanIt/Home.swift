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
    
    @State private var totalSeconds: Int = 0

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
                                    Text("You Finished Everything for Today!!!".lower())
                                        .padding([.top, .leading])
                                    Spacer()
                                }
                            }
                            
                            // MARK: In Progress
                            if checkInProgress != 0 {
                                HStack {
                                    Text("In Progress".lower())
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
                                                    totalSeconds += Int(assign.secondStop)
                                                }
                                            }
                                            .onDisappear {
                                                checkInProgress -= 1
                                                if !assign.isFinished {
                                                    totalSeconds -= Int(assign.secondStop)
                                                
                                                }
                                            }
//                                            .onChange(of: assign.secondStop / 60 % 60) { _ in
//                                                totalMinutes -=
//                                            }
                                    }
                                }
                            }
                            
                            // MARK: To Do
                            if checkToDo != 0 {
                                HStack {
                                    Text("To Do".lower())
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
                                                    totalSeconds += Int(assign.secondStop)                                                }
                                            }
                                            .onDisappear {
                                                checkToDo -= 1
                                                if !assign.isFinished {
                                                    totalSeconds -= Int(assign.secondStop)                                                }
                                            }
                                    }
                                }
                            }
                            
                            // MARK: Completed
                            if checkFinished != 0 {
                                HStack {
                                    Text("Completed Things!".lower())
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
                                                checkToDo += 1
                                                if !assign.isFinished {
                                                    totalSeconds += Int(assign.secondStop)                                                }
                                            }
                                            .onDisappear {
                                                checkToDo -= 1
                                                if !assign.isFinished {
                                                    totalSeconds -= Int(assign.secondStop)
                                                }
                                            }
                                    }
                                }
                            }
                            Group {
                                if checkFinished == 0 && checkToDo == 0 && checkInProgress == 0 {
                                    HStack {
                                        Text("Nothing Planned Tomorrow :)".lower())
                                            .padding([.top, .leading])
                                        Spacer()
                                    }
                                }
                                FormattedTime(secondStop: totalSeconds)
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
                .navigationTitle("Welcome back, Cunt!".lower())
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


