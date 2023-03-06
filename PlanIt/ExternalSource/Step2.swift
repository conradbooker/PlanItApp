//
//  Step1.swift
//  PlanIt
//
//  Created by Conrad on 3/4/23.
//

import SwiftUI

public func findCourses() -> [courseMatch] {
    let things: [ICSCal] = returnString().decodeJson([ICSCal].self)
    let assignments = things[0].VCALENDAR[0].VEVENT
    var dict: [String: String] = [:]
    var courseMatches: [courseMatch] = []
    
    for assignment in assignments {
        dict[assignment.course] = ""
    }
    
    for key in Array(dict.keys) {
        let courseMatchSingle = courseMatch()
        courseMatchSingle.onlineCourse = key
        courseMatchSingle.userCourse = ""
        courseMatches.append(courseMatchSingle)
    }
    
    return courseMatches
}

public class courseMatch: ObservableObject, Identifiable {
    @Published public var id = UUID().uuidString
    var onlineCourse: String = ""
    @Published public var userCourse: String = ""
}


struct Step2: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    @AppStorage("sourceURL") var sourceURL: String = ""
    @State private var saveDisabled: Bool = false
    @State private var showErrorText: Bool = false
    @Binding var state: String
    
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allCourses: FetchedResults<Course>
    
    @Binding var courses: [courseMatch]

    var body: some View {
        NavigationView {
            ScrollView {
                /// Video
                HStack {
                    Text("Match classes.".lower())
                        .padding(12)
                    Spacer()
                }
                Text("Please note: if you are missing a class, this is because your teacher has not assigned you work in this class. PlanIt will notify you in the future for any class updates. In the mean time, add assignments under this class manualy.".lower())
                    .padding(.horizontal,12)
                    .font(.subheadline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(courses) { course in
                            Text(course.onlineCourse)
                                .padding(.vertical, 12)
                                .font(.subheadline)
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach($courses) { course in
                            Picker("New Type", selection: course.userCourse) {
                                ForEach(allCourses, id: \.self) { cours in
                                        Text(cours.title ?? "")
                                            .tag(cours.title ?? "")
                                }
                            }.font(.subheadline)

                        }
                    }
                }

                HStack {
                    Button {
                        state = "Step1"
                    } label: {
                        HStack(spacing: 0) {
                            Image(systemName: "arrow.left")
                            Text("  Previous Step".lower())
                        }
                        .padding(2)
                    }
                    .buttonStyle(TimerButton(color: Color("timerDone")))
                    .padding()
                    
                    Spacer()
                    
                    Button {
                        state = "Step3"
                    } label: {
                        HStack(spacing: 0) {
                            Text("Next Step  ".lower())
                            Image(systemName: "arrow.right")
                        }
                        .padding(2)
                    }
                    .buttonStyle(TimerButton(color: Color("timerDone")))
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Sync Step 2/3".lower())
        }
    }
}

struct Step2_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        Step2(state: .constant("Step2"), courses: .constant(findCourses())).environment(\.managedObjectContext, persistedContainer.viewContext)

    }
}
