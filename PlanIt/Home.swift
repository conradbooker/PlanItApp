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
    
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
    @State private var currentDate: Date = Date.now
    @State private var selectedDate: Date = Date.now

    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    
    let calendar = Calendar.current
    
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    Color("cDarkGray")
                        .ignoresSafeArea()
                    ScrollView {
                        VStack {
                            HStack {
                                Text("Welcome back, Cunt!")
                                    .padding(.leading)
                                    .fontWeight(.bold)
                                    .font(.system(size: 30))
                                Spacer()
                            }
                            
                            HStack {
                                Text("Assignments to do heyyy")
                                    .padding(.leading)
                                Spacer()
                            }
                            
                            ForEach(allAssignments) { assign in
                                if assign.datePlanned!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                    if assign.status != "Finished!" {
                                        AssignmentView(assignment: assign).frame(width: geometry.size.width, height: 200).environment(\.managedObjectContext, persistedContainer.viewContext)
                                    }
                                }
                            }
                            
                            HStack {
                                Text("finished assignments")
                                    .padding(.leading)
                                Spacer()
                            }
                            

                            ForEach(allAssignments) { assign in
                                if assign.datePlanned!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                    if assign.status == "Finished!" {
                                        AssignmentView(assignment: assign).frame(width: geometry.size.width, height: 200).environment(\.managedObjectContext, persistedContainer.viewContext)
                                    }
                                }
                            }

                        }
                    }
                    VStack {
                        Spacer().frame(height:geometry.size.height-150)
                        VStack {
                            ZStack {
                                ZStack {
                                    VStack(spacing: 0) {
                                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                                            .datePickerStyle(.compact)
                                            
            //                                .accentColor(.orange)
                                        .labelsHidden()
                                        Spacer().frame(height:5)
                                    }
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color("cLessDarkGray"))
                                        .frame(width: geometry.size.width - 10,height:50)
                                        .allowsHitTesting(false)
                                        .shadow(radius: 2)
                                    HStack(spacing: 0) {
                                        Text(selectedDate.formatted(.dateTime.weekday(.wide)) + ", ")
                                        //calendar.dateComponents([.day], from: selectedDate).day ?? 0
                                        Text(selectedDate, style: .date)
                                    }
                                    .allowsHitTesting(false)

                                }
                                HStack {
                                    Button(action:{
                                        print("subtracted 1")
                                        subtract()
                                        impactMedium.impactOccurred()
                                    }){
                                        Image(systemName: "minus.circle.fill")
                                    }
                                    Spacer().frame(width:geometry.size.width-100)
                                    Button(action:{
                                        print("added 1")
                                        add()
                                        impactMedium.impactOccurred()
                                    }){
                                        Image(systemName: "plus.circle.fill")
                                    }
                                }


                                
                            }
                        }

                    }
                }
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
