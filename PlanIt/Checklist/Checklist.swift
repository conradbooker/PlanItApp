//
//  Agenda.swift
//  PlanIt
//
//  Created by Conrad on 3/2/23.
//

import SwiftUI

struct Checklist: View {
        
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    @FetchRequest(entity: Agenda.entity(), sortDescriptors: [NSSortDescriptor(key: "order", ascending: true)]) private var allAgendas: FetchedResults<Agenda>
    
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: true)]) private var allCourses: FetchedResults<Course>

    @AppStorage("accentColor") var accentColor: String = "aMint"
    
    var selectedDate: Date
    @State private var currentDate: Date = Date.now
    
    @State private var isPresented: Bool = false
    @State private var showAlert: Bool = false

    @State private var toDo: Int = 0
    @State private var completed: Int = 0

    private func getColor(_ title: String) -> Color {
        for course in allCourses {
            let colored = Color(red: CGFloat(course.red),green: CGFloat(course.green),blue: CGFloat(course.blue))
            if title.lowercased() == course.title?.lowercased() {
                return colored
            }
        }
        return .green
    }

    private func deleteAgenda(_ agenda: Agenda) {
        viewContext.delete(agenda)
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    var title: String {
        if selectedDate.formatted(.dateTime.day().month().year()) == currentDate.formatted(.dateTime.day().month().year()) {
            return "Things For Today".lower()
        }
        let weekdayIndex = Calendar.current.component(.weekday, from: selectedDate) - 1
        let weekday = DateFormatter().shortWeekdaySymbols[weekdayIndex]
        return "Things \(weekday), \(String(selectedDate.formatted(date: .abbreviated, time: .omitted)).dropLast(6))".lower()
    }
    
    @State var rotation = 0.0
    
    func rotate() {
        if isPresented {
            withAnimation(.linear(duration: 0.18)) { rotation += 45 }
        } else {
            withAnimation(.linear(duration: 0.18)) { rotation -= 45 }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("cDarkGray")
                    .ignoresSafeArea()
                ScrollView {
                    
                    if isPresented {
                        withAnimation(.linear) {
                            NewTask(selectedDate: selectedDate, isPresented: $isPresented, rotation: $rotation)
                                .environment(\.managedObjectContext, persistedContainer.viewContext)
                                .padding(.vertical)
                        }
                    }
                    if toDo > 0 {
                        HStack {
                            Text("Things To Do!".lower()).padding(.horizontal)
                            Spacer()
                        }
                    } else if completed == 0 {
                        HStack {
                            Text("Nothing To Do.".lower()).padding(.horizontal)
                            Spacer()
                        }
                    }
                    ForEach(allAgendas) { agenda in
                        if agenda.date!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) && !agenda.isCompleted {
                            withAnimation(.easeIn) {
                                TaskRow(agenda: agenda)
                                    .onAppear {
                                        toDo += 1
                                    }
                                    .onDisappear {
                                        toDo -= 1
                                    }
                            }
                        }
                    }
                    if completed > 0 {
                        HStack {
                            Text("Completed!".lower()).padding(.horizontal)
                            Spacer()
                        }
                    }
                    ForEach(allAgendas) { agenda in
                        if agenda.date!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) && agenda.isCompleted {
                            withAnimation(.easeIn) {
                                TaskRow(agenda: agenda)
                                    .onAppear {
                                        completed += 1
                                    }
                                    .onDisappear {
                                        completed -= 1
                                    }
                            }
                        }
                    }
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            if allCourses.count > 0 {
                                withAnimation(.linear) {
                                    isPresented.toggle()
                                }
                                rotate()
                            } else {
                                showAlert = true
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 100)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(Color(accentColor))
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                        }
                        .buttonStyle(CircleButton(color: Color(accentColor)))
                        .rotationEffect(.degrees(rotation))
                        .padding([.top, .bottom, .trailing], 20)
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Error".lower()),
                                message: Text("Please add a course first".lower())
                            )
                        }
                    }
                    Spacer().frame(height:125)
                }
            }
            .navigationTitle(title.lower())
        }.onAppear {
            
        }
    }
}

struct Checklist_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        Checklist(selectedDate: Date()).environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
