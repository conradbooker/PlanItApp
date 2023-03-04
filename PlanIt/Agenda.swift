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
    
    @State private var selectedDate: Date = Date.now
    @State private var currentDate: Date = Date.now
    
    @State private var isPresented: Bool = false

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
                    
                    ForEach(allAgendas) { agenda in
                        if Calendar.current.date(byAdding: .day, value: -1, to: agenda.date!)!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                            AgendaRow(agenda: agenda)
                        }
                    }
                }
                
                VStack {
                    Spacer()
                    DateSelector(selectedDate: $selectedDate)
                        .frame(width: UIScreen.screenWidth - 10)
                }
            }
            .navigationTitle(title.lower())
            .toolbar{
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
    }
}

struct Agenda_Previews: PreviewProvider {
    static var previews: some View {
        AgendaView()
    }
}
