//
//  ExternalSource.swift
//  PlanIt
//
//  Created by Conrad on 12/29/22.
//

import SwiftUI

private func findCourses() -> [courseMatch] {
    let assignments = onlineAssignmentData[0].VCALENDAR[0].VEVENT
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

struct ExternalSource: View {
    
    @State private var saveDisabled: Bool = true
    @State private var showErrorText: Bool = false
    @AppStorage("sourceURL") var sourceURL: String = ""
    var mySchoolAppSchoolList: [String] = ["Trinity Schhol NYC","Dalton"]
    let assignments = onlineAssignmentData[0].VCALENDAR[0].VEVENT
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer

    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allCourses: FetchedResults<Course>
    
//    let firstCourse = allCourses[0]
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
    
    @State private var courses: [courseMatch] = findCourses()
    
    private func getColor(_ title: String) -> Color {
        for course in allCourses {
            let colored = Color(red: CGFloat(course.red),green: CGFloat(course.green),blue: CGFloat(course.blue))
            if title.lowercased() == course.title?.lowercased() {
                return colored
            }
        }
        return .green
    }
    
    private func syncAssignments(_ courses: [courseMatch]) {
        var allCoursesDict: [String: String] = [:]
        
        for course in courses {
            allCoursesDict[course.onlineCourse] = course.userCourse
        }
        let things: [ICSCal] = returnString().decodeJson([ICSCal].self)
        let onlineAssignments = things[0].VCALENDAR[0].VEVENT
        
        /// assignment IDs
        var existingAssignmentIDs: [String] = []
        for assignment in allAssignments {
            existingAssignmentIDs.append(assignment.assignmentID!)
        }
        
        print(existingAssignmentIDs)
        
        if existingAssignmentIDs.contains("Personal Reflection20220912") {
            print("cupcakke")
        } else {
            print("Squidward")
        }
        
        /// main function crap
        for assign in onlineAssignments {
            if existingAssignmentIDs.contains(String(assign.id)) == false {
                print("ID:")
                print(String(assign.id))
                let dateFormatter = DateFormatter()
                let currentCourse = allCoursesDict[assign.course] ?? ""
                dateFormatter.dateFormat = "YYYYMMdd"
                
                let assignment = Assignment(context: viewContext)
                assignment.activeHours = 0
                assignment.activeMinutes = 0
                assignment.activeSeconds = 0
                assignment.dubiousMinutes = 0
                assignment.minuteStop = 0
                assignment.hourStop = 0
                assignment.totalHours = 0
                assignment.totalMinutes = 0
                assignment.totalSeconds = 0
                
                assignment.red = Float(getColor(currentCourse).components.red)
                assignment.green = Float(getColor(currentCourse).components.green)
                assignment.blue = Float(getColor(currentCourse).components.blue)
                assignment.opacity = 0.0
                        
                assignment.assignmentType = "Homework"
                assignment.course = currentCourse
                assignment.source = "fromOnline"
                assignment.summary = assign.description
                assignment.title = assign.title
                
                assignment.dateCreated = Date()
                assignment.dateFinished = Date()
                
                if assign.dueDate < Date() {
                    assignment.status = "Finished!"
                } else {
                    assignment.status = "To Do"
                }
                
                assignment.datePlanned = Calendar.current.date(byAdding: .day, value: -1000, to: assign.dueDate)
                assignment.isPlanned = false
                assignment.dueDate = assign.dueDate
                
                assignment.courseID = UUID()
                assignment.id = UUID()
                assignment.assignmentID = assign.title + assign.DTEND.dropFirst(11)

                print(assignment.assignmentID!)
                assignment.isFinished = false
                
                assignment.parentCourse = ""
                assignment.isChild = false
                assignment.isParent = false
                            
                assignment.parentID = ""
                assignment.parentAssignmentTitle = ""
                assignment.isPaused = true

                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                    print("Error occured in saving! (parent)")
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            } else {
                print("poopi")
            }
        }
        
        for matchCourse in courses {
            for course in allCourses {
                if course.title == matchCourse.userCourse {
                    course.onlineTitle = matchCourse.onlineCourse
                    do {
                        try viewContext.save()
                    } catch {
                        print(error.localizedDescription)
                        print("Error occured in saving! (parent)")
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
            }
        }
        
    }

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    Text("This app supports only 'Schoology', or Blackbaud's 'myschoolapp' for homework assignments. If you do not use either of these services, please go to [this form] for help.")
                        .padding()
                    TextField("Link", text: $sourceURL)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .onChange(of: sourceURL) { _ in
                            if sourceURL == "" { saveDisabled = true }
                            else { saveDisabled = false }
                        }
                    Button("Save") {
                        if sourceURL.contains("cal") || sourceURL.contains("iCal") || sourceURL.contains("ical") || sourceURL.contains(".ics") || sourceURL.contains("ics") || sourceURL == "" {
                            if sourceURL.contains("https://") && !sourceURL.contains("webcal://") {
                                loadJSonURL()
                            } else if sourceURL.contains("webcal://") {
                                sourceURL = sourceURL.replacingOccurrences(of: "webcal://", with: "")
                                loadJSonURL()
                            } else {
                                sourceURL = "https://" + sourceURL
                                loadJSonURL()
                            }
                        } else {
                            showErrorText = true
                        }
                    }.disabled(saveDisabled)
                    
                    if showErrorText {
                        Text("Error, not a valid URL. If this is a valid URL, click this button. If this is not a propper url, this will crash the app.")
                            .padding()
                    }
                }
                                
                Group {
                    Spacer().frame(height: 20)
                    Text("Step 1/2: Match classes from myschoolapp to these your classes.")
                    Text("Please note: if you are missing a class, this is because your teacher has not assigned you work in this class. PlanIt will notify you in the future for any class updates. In the mean time, add assignments under this class manualy.")
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
                }
                Group {
                    Spacer().frame(height: 20)
                    Text("Step 2/2: Check if these are right!")
                    ForEach(courses) { course in
                        Text("\(course.onlineCourse): \(course.userCourse)")
                            .padding(.vertical, 5)
                    }
                }
                Button("Sync!!!") {
                    syncAssignments(courses)
                }
            }
        }
    }
}

struct ExternalSource_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        ExternalSource().environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
