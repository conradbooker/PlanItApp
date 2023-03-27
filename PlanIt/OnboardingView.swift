//
//  OnboardingView.swift
//  PlanIt
//
//  Created by Conrad on 3/19/23.
//

import SwiftUI

struct OnboardingView: View { // Main
    @State private var view: Int = 0
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    @Binding var done: Bool

    var body: some View {
        switch view {
        case 0: Onboarding1(view: $view)
                .environment(\.managedObjectContext, persistedContainer.viewContext)
        case 1: Onboarding2(view: $view)
                .environment(\.managedObjectContext, persistedContainer.viewContext)
        case 2: Onboarding3(view: $view)
                .environment(\.managedObjectContext, persistedContainer.viewContext)
        case 3: Onboarding4(view: $view, done: $done)
                .environment(\.managedObjectContext, persistedContainer.viewContext)
        case 4: ContentView()
            .environment(\.managedObjectContext, persistedContainer.viewContext)
        default:
            Onboarding1(view: $view)
                .environment(\.managedObjectContext, persistedContainer.viewContext)
        }
        /// View 1: Plan your assignments
        /// View 2: Sync from external source (not actually sync)
        /// View 3: Customise
        /// View 4: OnBoarding Settings
    }
}



struct Onboarding1: View { // Assignments
    @Binding var view: Int
    @AppStorage("accentColor") var accentColor: String = "aMint"
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    let date = NSDate(timeIntervalSince1970: 1415637900)

    var body: some View {
        ZStack {
            Color("cDarkGray")
                .ignoresSafeArea()
            
            NavigationView {
                ScrollView {
                    VStack {
                        VStack(spacing: 0) {
                            HStack {
                                Text("All homework assignments in one place!")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .padding(10)
                                Spacer()
                            }
                            .padding(.top, 20.0)
                            HStack {
                                Text("Some peace from the chaos of school")
                                    .padding(.horizontal, 10)
                                Spacer()
                            }
                        }
                        Spacer().frame(height: 20)
                        
                        Group {
                            HStack {
                                Text("Homework").padding(.leading,10)
                                Spacer()
                            }
                            AssignmentViewStatic(title: "HW 5.3 - Forced Oscillations Worksheet", course: "Physics C - Period 2", type: "Homework", due: date as Date, seconds: 920, color: Color("aRed"))
                            AssignmentViewStatic(title: "Introduction to integrals", course: "Calc - Period 4", type: "Homework", due: date as Date, seconds: 920, color: Color("aOrange"))
                            HStack {
                                Text("Assessments / Projects").padding([.leading,.top],10)
                                Spacer()
                            }
                            AssignmentViewStatic(title: "新疆 PowerPoint 演示文稿", course: "中文 - Period 1", type: "Test", due: date as Date, seconds: 920, color: Color("aYellow"))
                            AssignmentViewStatic(title: "Beloved Chapter 6-8 Quiz", course: "English - Period 3", type: "Quiz", due: date as Date, seconds: 920, color: Color("aGreen"))
                            AssignmentViewStatic(title: "A* Path Finding project due via GradeScope", course: "CS 4 - Period 6", type: "Project", due: date as Date, seconds: 920, color: Color("aBlue"))
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                withAnimation(.linear) { view = 1 }
                            } label: {
                                HStack {
                                    Text("Next")
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .padding()
                            .buttonStyle(TimerButton(color: Color(accentColor)))
                        }
                        .padding(.bottom, 20)
                    }
                }
                .navigationTitle("All homework assignments in one place")
            }
        }
    }
}

struct Onboarding2: View { // Sync
    @Binding var view: Int
    @AppStorage("accentColor") var accentColor: String = "aMint"
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    var body: some View {
        ZStack {
            Color("cDarkGray")
                .ignoresSafeArea()
            NavigationView {
                ScrollView {
                    VStack {
                        HStack {
                            Text("No need to rely on your school's homework website for assignments anymore! And all assignments are stored to this device.")
                                .padding(.horizontal, 10)
                            Spacer()
                        }
                        Spacer().frame(height:100)
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 100))
                            .fontWeight(.heavy)
                        Spacer()
                        HStack {
                            Button {
                                withAnimation(.linear) { view = 0 }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.left")
                                    Text("Previous")
                                }
                            }
                            .buttonStyle(TimerButton(color: Color(accentColor)))
                            .padding()
                            Spacer()
                            Button {
                                withAnimation(.linear) { view = 2 }
                            } label: {
                                HStack {
                                    Text("Next")
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .buttonStyle(TimerButton(color: Color(accentColor)))
                            .padding()
                        }
                        .padding(.bottom, 20)
                    }
                }
                .navigationTitle("Sync from external source")
            }
        }
    }
}

struct Onboarding3: View { // Agenda
    @Binding var view: Int
    @AppStorage("accentColor") var accentColor: String = "aMint"
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer

    var body: some View {
        ZStack {
            Color("cDarkGray")
                .ignoresSafeArea()
            NavigationView {
                ScrollView {
                    VStack {
                        VStack(spacing: 0) {
                            HStack {
                                Text("Stay on top of things with the Agenda feature.")
                                    .padding(.horizontal, 10)
                                Spacer()
                            }
                        }
                        Spacer().frame(height: 20)
                        
                        Group {
                            HStack {
                                Text("Agenda").padding(.leading,10)
                                Spacer()
                            }
                            TaskRowStatic(title: "Clean room", group: "Tasks", color: .gray)
                            TaskRowStatic(title: "Visit with grandma", group: "Agenda", color: .black)
                            TaskRowStatic(title: "Dinner with fam", group: "Agenda", color: .black)
                            TaskRowStatic(title: "Calc Homework", group: "Calc", color: .orange)
                            TaskRowStatic(title: "Physics Homework", group: "Physics", color: .red)
                            TaskRowStatic(title: "CS Study", group: "CS", color: .blue)
                        }
                        Spacer()
                        HStack {
                            Button {
                                withAnimation(.linear) { view = 1 }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.left")
                                    Text("Previous")
                                }
                            }
                            .buttonStyle(TimerButton(color: Color(accentColor)))
                            .padding()
                            Spacer()
                            Button {
                                withAnimation(.linear) { view = 3 }
                            } label: {
                                HStack {
                                    Text("Next")
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .padding()
                            .buttonStyle(TimerButton(color: Color(accentColor)))
                        }
                        .padding(.bottom, 20)
                    }
                }
                .navigationTitle("Plan out your day")
            }
        }
    }
}

struct Onboarding4: View { // Quick start
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer

    @Binding var view: Int
    @AppStorage("disableTimer") var disableTimer: Bool = false
    @AppStorage("aestheticMode") var aestheticMode: Bool = false
    @AppStorage("twofourhourtime") var twofourhourtime: Bool = false
    @AppStorage("bgColor") var bgColor: String = ""
    @AppStorage("fgColor") var fgColor: String = ""
    @AppStorage("darkMode") var darkMode: Int = 3
    @AppStorage("accentColor") var accentColor: String = "aMint"
    @AppStorage("name") var name: String = "new user"
    @AppStorage("onBoarding") var onBoarded: Bool = false
    
    @FocusState private var inputIsActive: Bool
    
    @State private var isPressed1: Bool = false
    @State private var isPressed2: Bool = false
    @State private var isPressed3: Bool = true

    @Binding var done: Bool

    var body: some View {
        ZStack {
            Color("cDarkGray")
                .ignoresSafeArea()
            NavigationView {
                ScrollView {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 2)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Name:")
                                    .padding()
                                TextField("Name", text: $name)
                                    .background(Color("cLessDarkGray"))
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal)
                                    .focused($inputIsActive)
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("done") {
                                                inputIsActive = false
                                            }
                                        }
                                    }
                                
                                Toggle("Show Assignment Timers".lower(), isOn: $disableTimer)
                                    .tint(Color(accentColor))
                                    .padding([.top, .leading, .trailing])
                                
                                Toggle("Aesthetic Mode".lower(), isOn: $aestheticMode)
                                    .tint(Color(accentColor))
                                    .padding([.top, .leading, .trailing])
                                
                                Text("Accent Color:".lower())
                                    .padding([.top, .leading, .trailing])
                                HStack {
                                    ForEach(aColors, id: \.self) { color in
                                        Button {
                                            withAnimation(.linear(duration: 1)) {
                                                accentColor = color
                                            }
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(Color(color))
                                                    .shadow(radius: 2)
                                                if accentColor == color {
                                                    withAnimation(.linear(duration: 1)) {
                                                        Circle()
                                                            .frame(width: 10, height: 10)
                                                            .foregroundColor(.black)
                                                    }
                                                }
                                            }
                                        }
                                        .buttonStyle(upDown())
                                    }
                                }
                                .padding([.top, .leading, .trailing])
                                
                                Text("Color Scheme:".lower())
                                    .padding([.top, .leading, .trailing])
                                HStack {
                                    VStack {
                                        Button {
                                            withAnimation(.linear(duration: 0.1)) {
                                                darkMode = 0
                                            }
                                        } label: {
                                            HStack {
                                                Text("Light")
                                                    .foregroundColor(.black)
                                                Image(systemName: "sun.max.fill")
                                                    .foregroundColor(.black)
                                            }
                                            .padding(.vertical, 2)
                                        }
                                        .buttonStyle(ToggleButton(color: .white))
                                        if darkMode == 0 {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 40, height: 3)
                                                .foregroundColor(Color(accentColor))
                                                .shadow(radius: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 40, height: 3)
                                                .foregroundColor(Color("cLessDarkGray"))
                                        }
                                    }
                                    
                                    VStack {
                                        Button {
                                            withAnimation(.linear(duration: 0.1)) {
                                                darkMode = 1
                                            }
                                        } label: {
                                            HStack {
                                                Text("Dark")
                                                    .foregroundColor(.white)
                                                Image(systemName: "moon.fill")
                                                    .foregroundColor(.white)
                                            }
                                            .padding(.vertical, 2)
                                        }
                                        .buttonStyle(ToggleButton(color: .black))
                                        if darkMode == 1 {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 40, height: 3)
                                                .foregroundColor(Color(accentColor))
                                                .shadow(radius: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 40, height: 3)
                                                .foregroundColor(Color("cLessDarkGray"))
                                        }
                                    }
                                    
                                    VStack {
                                        Button {
                                            withAnimation(.linear(duration: 0.1)) {
                                                isPressed1 = false
                                                isPressed2 = false
                                                isPressed3 = true
                                                darkMode = 2
                                            }
                                        } label: {
                                            HStack {
                                                Text("System")
                                                    .foregroundColor(.white)
                                            }
                                            .padding(.vertical, 2)
                                        }
                                        .buttonStyle(ToggleButton(color: .gray))
                                        if darkMode == 2 {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 40, height: 3)
                                                .foregroundColor(Color(accentColor))
                                                .shadow(radius: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 40, height: 3)
                                                .foregroundColor(Color("cLessDarkGray"))
                                        }
                                    }
                                }
                                .padding([.top, .leading, .trailing])

                                
            //                    HStack {
            //                        Text("Add classes (you can always add classes later):".lower())
            //                            .padding()
            //                        Spacer()
            //                        Button {
            //
            //                        } label: {
            //                            Image(systemName: "plus")
            //                                .font(.title2)
            //                                .fontWeight(.semibold)
            //                                .frame(width: 30,height: 30)
            //                        }
            //                        .buttonStyle(CircleButton(color: Color(accentColor)))
            //                        .padding()
            //                    }
                                Spacer()
                                Text("PlanIt App does not collect any user data.")
                                    .padding()
                                    .font(.footnote)
                            }
                        }
                        .padding()
                        .frame(height: 550)

                        Spacer()
                        HStack {
                            Button {
                                withAnimation(.linear) { view = 2 }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.left")
                                    Text("Previous")
                                }
                            }
                            .padding()
                            .buttonStyle(TimerButton(color: Color(accentColor)))
                            Spacer()
                            Button {
                                withAnimation(.linear) { view = 4 }
                                onBoarded = true
                                done = false
                            } label: {
                                HStack {
                                    Text("Done!")
                                    Image(systemName: "checkmark")
                                }
                            }
                            .padding()
                            .buttonStyle(TimerButton(color: Color(accentColor)))
                        }
                        .padding(.bottom, 20)
                    }
                }
                .navigationTitle("Customiation!!".lower())
            }
        }
    }
}

struct ToggleButton: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding(5.0)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 2)
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(done: .constant(true))
    }
}
