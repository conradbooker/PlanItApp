//
//  AgendaRow.swift
//  PlanIt
//
//  Created by Conrad on 3/3/23.
//

import SwiftUI

struct AgendaRow: View {
    var agenda: Agenda
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
            
    @State private var showEdit: Bool = false
    @State private var courseSize = CGSize()
    @State private var titleSize = CGSize()
    @State private var dueDateSize = CGSize()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 15, height: courseSize.height + titleSize.height + dueDateSize.height + 5)
                    .shadow(radius: 3)
                    .foregroundColor(Color(red: CGFloat(agenda.red), green: CGFloat(agenda.green), blue: CGFloat(agenda.blue)))
                
                Spacer()
                    .frame(width: 5)
                
                ZStack {
                    HStack {
                        Text(agenda.title ?? "")
                            .fontWeight(.medium)
                            .padding(.leading, 6)
                        Spacer()
                    }
                    .padding(.top, 4)
                    .readSize { size in
                        titleSize = size
                    }
                    .opacity(0)
                    Button {
                        showEdit = true
                    } label: {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color("cLessDarkGray"))
                            .shadow(radius: 3)
                            .frame(height: courseSize.height + titleSize.height + 5)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // MARK: course
                        HStack {
                            VStack(spacing: 0) {
                            HStack {
                                Text((agenda.group ?? "Error"))
                                    .font(.subheadline)
                                    .padding(.leading, 6)
                                Spacer()
                            }
                            .padding(.top, 4)
                            .readSize { size in
                                courseSize = size
                            }
                            
                            // MARK: title
                            HStack {
                                Text(agenda.title ?? "Error nothing loaded")
                                    .fontWeight(.medium)
                                    .padding(.leading, 6)
                                Spacer()
                            }
                            .readSize { size in
                                titleSize = size
                            }
                            .padding(.top, 4)
                            .padding(.bottom, 6)
                        }
                            Button {
                                do {
                                    agenda.isCompleted.toggle()
                                    try viewContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } label: {
                                Image(systemName: !agenda.isCompleted ? "square" : "checkmark.square.fill")
                            }
                            .buttonStyle(TimerButton(color: Color("timerDone")))
                        
                            Spacer()
                        }
                    }
                    
                }
                .frame(width: UIScreen.screenWidth * 5.5/6)
                
            }
            .frame(width: UIScreen.screenWidth - 10)
        }
    }
}

struct AgendaRow_Previews: PreviewProvider {
    @Environment(\.managedObjectContext) static var viewContext
    
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        AgendaRow(agenda: Agenda(context: viewContext))
            .environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
