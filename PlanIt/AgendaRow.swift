//
//  AgendaRow.swift
//  PlanIt
//
//  Created by Conrad on 3/3/23.
//

import SwiftUI

struct AgendaRowNew: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
            
    @State private var showEdit: Bool = false
    @State private var courseSize = CGSize()
    @State private var titleSize = CGSize()
    @State private var dueDateSize = CGSize()
    
    @State private var title: String = ""
    @State private var courseTitle: String = ""
    @State private var red: Float = 0
    @State private var green: Float = 0
    @State private var blue: Float = 0
    
    @State private var tapped: Bool = false

    @FocusState private var inputIsActive: Bool
    
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: true)]) private var allCourses: FetchedResults<Course>

    @FetchRequest(entity: Agenda.entity(), sortDescriptors: [NSSortDescriptor(key: "order", ascending: true)]) private var allAgendas: FetchedResults<Agenda>
    
    var selectedDate: Date
    
    @Binding var isPresented: Bool

    
    private func getColor(_ title: String) -> Color {
        for course in allCourses {
            let colored = Color(red: CGFloat(course.red),green: CGFloat(course.green),blue: CGFloat(course.blue))
            if title.lowercased() == course.title?.lowercased() {
                return colored
            }
        }
        return .green
    }
    
    private func tapCourse() -> String {
        if !tapped {
            let firstCourse = allCourses[0]
            return firstCourse.title ?? "Error lol"
        }
        return courseTitle
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 15, height: courseSize.height + titleSize.height + dueDateSize.height + 5)
                    .shadow(radius: 3)
                    .foregroundColor(getColor(tapCourse()))
                
                Spacer()
                    .frame(width: 5)
                
                ZStack {
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
                                    TextField("Enter title", text: $title, axis: .vertical)
                                        .background(Color("cDarkGray"))
                                        .textFieldStyle(.roundedBorder)
                                        .padding([.top, .leading, .trailing],4)
                                        .padding(.leading,4)
                                        .focused($inputIsActive)
                                        .toolbar {
                                            ToolbarItemGroup(placement: .keyboard) {
                                                Spacer()
                                                Button("Done".lower()) {
                                                    inputIsActive = false
                                                }
                                            }
                                        }

                                    Spacer()
                                }
                                .padding(.top, 4)
                                .padding(.bottom, 6)
                                .readSize { size in
                                    courseSize = size
                                }
                            
                            // MARK: title
                                HStack(spacing: 0) {
                                    Text("Course:")
                                        .padding(.leading,10)
                                    Picker("Classes", selection: $courseTitle) {
                                        ForEach(allCourses, id: \.self) { course in
                                            Text(course.title ?? "").tag(course.title ?? "")
                                        }
                                    }
                                    .onTapGesture {
                                        tapped = true
                                    }
                                    Spacer()
                                }
                                .readSize { size in
                                    titleSize = size
                                }
                                .padding(.bottom, 4)
                            }
                            Button {
                                do {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "YYYYMMdd"

                                    let agenda = Agenda(context: viewContext)
                                    agenda.date = selectedDate
                                    
                                    agenda.isCompleted = false
                                    agenda.group = tapCourse()
                                    agenda.assignmentID = ""
                                    agenda.title = title
                                    agenda.id = title + dateFormatter.string(from: selectedDate)
                                    agenda.red = Float(getColor(tapCourse()).components.red)
                                    agenda.green = Float(getColor(tapCourse()).components.green)
                                    agenda.blue = Float(getColor(tapCourse()).components.blue)
                                    agenda.order = 0
                                    agenda.summary = ""
                                    
                                    isPresented = false
                                    
                                    try viewContext.save()
                                    print("saved")
                                    print(agenda.date ?? Date())
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } label: {
                                Image(systemName: "checkmark.square")
                            }
                            .buttonStyle(TimerButton(color: Color("timerStart")))
                        
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
                                    print(agenda.isCompleted)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } label: {
                                if agenda.isCompleted {
                                    Image(systemName: "checkmark.square.fill")
                                } else {
                                    Image(systemName: "square")
                                }
                                
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
        AgendaRowNew(selectedDate: Date(), isPresented: .constant(false))
            .environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
