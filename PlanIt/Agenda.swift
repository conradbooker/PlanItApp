//
//  Agenda.swift
//  PlanIt
//
//  Created by Conrad on 3/2/23.
//

import SwiftUI

struct AgendaView: View {
    
    func add() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
    }
    func subtract() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    @FetchRequest(entity: Agenda.entity(), sortDescriptors: [NSSortDescriptor(key: "order", ascending: true)]) private var allAgendas: FetchedResults<Agenda>
    
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: true)]) private var allCourses: FetchedResults<Course>

    
    
    @State private var selectedDate: Date = Date.now
    @State private var currentDate: Date = Date.now
    
    @State private var isPresented: Bool = false
    
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
            return "Agenda For Today"
        }
        let weekdayIndex = Calendar.current.component(.weekday, from: selectedDate) - 1
        let weekday = DateFormatter().shortWeekdaySymbols[weekdayIndex]
        return "Agenda \(weekday), \(String(selectedDate.formatted(date: .abbreviated, time: .omitted)).dropLast(6))"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("cDarkGray")
                
                ScrollView {
                    
                    if isPresented {
                        AgendaRowNew(selectedDate: selectedDate, isPresented: $isPresented)
                            .environment(\.managedObjectContext, persistedContainer.viewContext)
                            .padding(.vertical)
                    }
                    
                    HStack {
                        Text("Things To Do!".lower()).padding(.horizontal)
                        Spacer()
                    }
                                        
                    ForEach(allAgendas) { agenda in
                        if agenda.date!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) && !agenda.isCompleted {
                            AgendaRow(agenda: agenda)
                            Button {
                                deleteAgenda(agenda)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                    HStack {
                        Text("Completed!".lower()).padding(.horizontal)
                        Spacer()
                    }
                                        
                    ForEach(allAgendas) { agenda in
                        if agenda.date!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) && agenda.isCompleted {
                            AgendaRow(agenda: agenda)
                            Button {
                                deleteAgenda(agenda)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }

                }
                
                VStack(spacing: 0) {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            isPresented = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 50)
                                    .frame(width: 50,height: 50)
                                    .shadow(radius: 2)
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                            .padding([.top, .bottom, .trailing], 6.0)
                        }
                    }
                    DateSelector(selectedDate: $selectedDate)
                        .frame(width: UIScreen.screenWidth - 10)
                }
            }
            .navigationTitle(title.lower())
        }.onAppear {
            
        }
    }
}

struct AgendaView_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        AgendaView().environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
