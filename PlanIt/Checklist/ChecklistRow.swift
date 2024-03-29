//
//  AgendaRow.swift
//  PlanIt
//
//  Created by Conrad on 3/3/23.
//

import SwiftUI

struct NewTask: View {
    
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
    
    @Binding var rotation: Double
    
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
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color("cLessDarkGray"))
                        .shadow(radius: 3)
                        .frame(height: courseSize.height + titleSize.height + 5)
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
                                    Text("Group:".lower())
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
                                if title != "" {
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
                                    withAnimation(.linear(duration: 0.18)) { rotation -= 45 }
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





struct TaskRow: View {
    var agenda: Agenda
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
            
    @State private var showEdit: Bool = false
    @State private var courseSize = CGSize()
    @State private var titleSize = CGSize()
    @State private var dueDateSize = CGSize()
    @State private var offset = CGFloat()
    
    @State private var showDeleteButton: Bool = false
    @State private var toggled: Bool = false
    @State private var toggled2: Bool = false
    @State private var revert: Bool = false
    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    
    private func deleteAgenda(_ agenda: Agenda) {
        withAnimation(.easeOut) { viewContext.delete(agenda) }
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
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
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color("cLessDarkGray"))
                        .shadow(radius: 3)
                        .frame(height: courseSize.height + titleSize.height + 5)
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
                            successHaptics()
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
            .offset(x: offset, y: 0)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 && gesture.translation.width > -20 {
                            if gesture.translation.width <= -15 {
                                impactMedium.impactOccurred()
                            }
                            offset = gesture.translation.width
                            print(gesture.translation)
                        } else if gesture.translation.width > 0 && showDeleteButton {
                            revert = true
                            withAnimation(.easeOut) { showDeleteButton = false }
                        }
                        
                    }
                    .onEnded { _ in
                        if offset <= -15 && !revert {
                            print("doing")
                            let count = 1...500
                            withAnimation(.easeIn) { showDeleteButton = true }
                            for _ in count {
                                withAnimation(.easeIn(duration: 0.1)) {
                                    if offset > -50 { offset -= 1 }
                                }
//                                impactMedium.impactOccurred()
                            }
                            // remove the card
                        } else if offset > -15 && !revert {
                            withAnimation(.easeOut) { showDeleteButton = false }
                            offset = .zero
                            toggled = false
                        } else if revert {
                            withAnimation(.easeOut) { showDeleteButton = false }
                            withAnimation(.easeIn(duration: 0.1)) { offset = .zero }
                            toggled = false
                            revert = false
                        }
                    }
            )
            .frame(width: UIScreen.screenWidth - 10)
            if showDeleteButton {
                Button {
                    deleteAgenda(agenda)
                    successHaptics()
                } label: {
                    Image(systemName: "trash")
                        .font(.title2)
                }
                .padding(.leading, -38)
            }
        }
    }
}

struct TaskRowStatic: View {
    var title: String
    var group: String
    var color: Color

    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    @State private var completed: Bool = false
            
    @State private var showEdit: Bool = false
    @State private var courseSize = CGSize()
    @State private var titleSize = CGSize()
    @State private var dueDateSize = CGSize()
    @State private var offset = CGFloat()
    
    @State private var showDeleteButton: Bool = false
    @State private var toggled: Bool = false
    @State private var toggled2: Bool = false
    @State private var revert: Bool = false
    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    
    private func deleteAgenda(_ agenda: Agenda) {
        withAnimation(.linear) { viewContext.delete(agenda) }
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 15, height: courseSize.height + titleSize.height + dueDateSize.height + 5)
                    .shadow(radius: 3)
                    .foregroundColor(color)
                
                Spacer()
                    .frame(width: 5)
                
                ZStack {
                    HStack {
                        Text(title)
                            .fontWeight(.medium)
                            .padding(.leading, 6)
                        Spacer()
                    }
                    .padding(.top, 4)
                    .readSize { size in
                        titleSize = size
                    }
                    .opacity(0)
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color("cLessDarkGray"))
                        .shadow(radius: 3)
                        .frame(height: courseSize.height + titleSize.height + 5)
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // MARK: course
                        HStack {
                            VStack(spacing: 0) {
                            HStack {
                                Text(group)
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
                                Text(title)
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
                            successHaptics()
                        } label: {
                            if completed {
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
            .offset(x: offset, y: 0)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 && gesture.translation.width > -20 {
                            if gesture.translation.width <= -15 {
                                impactMedium.impactOccurred()
                            }
                            offset = gesture.translation.width
                            print(gesture.translation)
                        } else if gesture.translation.width > 0 && showDeleteButton {
                            revert = true
                            withAnimation(.easeOut) { showDeleteButton = false }
                        }
                        
                    }
                    .onEnded { _ in
                        if offset <= -15 && !revert {
                            print("doing")
                            let count = 1...500
                            withAnimation(.easeIn) { showDeleteButton = true }
                            for _ in count {
                                withAnimation(.easeIn(duration: 0.1)) {
                                    if offset > -50 { offset -= 1 }
                                }
//                                impactMedium.impactOccurred()
                            }
                            // remove the card
                        } else if offset > -15 && !revert {
                            withAnimation(.easeOut) { showDeleteButton = false }
                            offset = .zero
                            toggled = false
                        } else if revert {
                            withAnimation(.easeOut) { showDeleteButton = false }
                            withAnimation(.easeIn(duration: 0.1)) { offset = .zero }
                            toggled = false
                            revert = false
                        }
                    }
            )
            .frame(width: UIScreen.screenWidth - 10)
            if showDeleteButton {
                Button {
                    successHaptics()
                } label: {
                    Image(systemName: "trash")
                        .font(.title2)
                }
                .padding(.leading, -38)
            }
        }
    }
}


struct TaskRow_Previews: PreviewProvider {
    @Environment(\.managedObjectContext) static var viewContext
    
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        TaskRow(agenda: Agenda(context: viewContext))
            .environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
