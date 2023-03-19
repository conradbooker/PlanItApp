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
    
    @State var rotation = 0.0
    
    func rotate() {
        if rotation < 45 {
            while rotation < 45 {
                withAnimation(.linear) { rotation += 1 }
            }
        } else {
            while rotation > 0 {
                withAnimation(.linear) { rotation -= 1 }
            }
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
                            NewTask(selectedDate: selectedDate, isPresented: $isPresented)
                                .environment(\.managedObjectContext, persistedContainer.viewContext)
                                .padding(.vertical)
                        }
                    }
                    
                    HStack {
                        Text("Things To Do!".lower()).padding(.horizontal)
                        Spacer()
                    }
                                        
                    ForEach(allAgendas) { agenda in
                        if agenda.date!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) && !agenda.isCompleted {
                            withAnimation(.easeIn) { TaskRow(agenda: agenda) }
                        }
                    }
                    HStack {
                        Text("Completed!".lower()).padding(.horizontal)
                        Spacer()
                    }
                                        
                    ForEach(allAgendas) { agenda in
                        if agenda.date!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) && agenda.isCompleted {
                            withAnimation(.easeIn) { TaskRow(agenda: agenda) }
                        }
                    }
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.linear) {
                                isPresented.toggle()
                            }
                            rotate()
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
