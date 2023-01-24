//
//  Planner.swift
//  PlanIt
//
//  Created by Conrad on 12/24/22.
//

import SwiftUI

extension Date {

  static func today() -> Date {
      return Date()
  }

  func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
    return get(.next,
               weekday,
               considerToday: considerToday)
  }

  func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
    return get(.previous,
               weekday,
               considerToday: considerToday)
  }

  func get(_ direction: SearchDirection,
           _ weekDay: Weekday,
           considerToday consider: Bool = false) -> Date {

    let dayName = weekDay.rawValue

    let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }

    assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")

    let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1

    let calendar = Calendar(identifier: .gregorian)

    if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
      return self
    }

    var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
    nextDateComponent.weekday = searchWeekdayIndex

    let date = calendar.nextDate(after: self,
                                 matching: nextDateComponent,
                                 matchingPolicy: .nextTime,
                                 direction: direction.calendarSearchDirection)

    return date!
  }

}

// MARK: Helper methods
extension Date {
  func getWeekDaysInEnglish() -> [String] {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar.weekdaySymbols
  }

  enum Weekday: String {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
  }

  enum SearchDirection {
    case next
    case previous

    var calendarSearchDirection: Calendar.SearchDirection {
      switch self {
      case .next:
        return .forward
      case .previous:
        return .backward
      }
    }
  }
}


func checkMondays(_ date: Date) -> Date {
    let lastMonday = date.previous(.monday)
    if date.formatted(.dateTime.weekday(.wide)) == "Monday" {
        return date
    } else {
        return lastMonday
    }
}

struct Planner: View {
    
    @AppStorage("initialSync") var initialSync: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allCourses: FetchedResults<Course>
    
    var assignmentSpacing: CGFloat = 5
        
    @State private var selectedDate: Date = Date()

    let calendar = Calendar.current

    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    
    private func findHeight(_ text: String) -> CGFloat {
        if Double(text.count) / 40 < 1.2 {
            return 135
        }
        return CGFloat((text.count / 40) * 17 + 140)
    }

    @State var checkInProgress: Int = 0
    @State var checkToDo: Int = 0
    @State var checkFinished: Int = 0
    
    @State var assignmentSize =  CGSize()

    
    @State private var startDate = Date()
    @State private var stopDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    
    func add() {
        startDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
        stopDate = Calendar.current.date(byAdding: .day, value: 7, to: stopDate)!
    }
    
    func subtract() {
        startDate = Calendar.current.date(byAdding: .day, value: -7, to: startDate)!
        stopDate = Calendar.current.date(byAdding: .day, value: -7, to: stopDate)!
    }
    @State private var currentNumberOfAssignments: Int = 0
    
    
    var body: some View {
        ZStack {
            Color("cDarkGray")
                .ignoresSafeArea()
            NavigationView {
                ScrollView {
                    if currentNumberOfAssignments == 0 {
                        HStack {
                            Text("no assignments")
                                .padding(.leading, 6)
                            Spacer()
                        }
                    } else {
                        HStack {
                            Text("assignments to plan")
                                .padding(.leading, 6)
                            Spacer()
                        }
                    }
                    // MARK: assignments
                    ForEach(allAssignments) { assign in
                        if assign.isPlanned == false && Calendar.current.isDate(assign.dueDate!, equalTo: selectedDate, toGranularity: .day) {
                            PlannerRow(assignment: assign)
                                .environment(\.managedObjectContext, persistedContainer.viewContext)
                                .onAppear {
                                    currentNumberOfAssignments += 1
                                }
                                .onDisappear {
                                    currentNumberOfAssignments -= 1
                                }
                        }
                    }
                    Spacer().frame(height: 100)
                }.navigationTitle("Planner")
            }
            VStack {
                Spacer().frame(height: 500)
                DateSelector(selectedDate: $selectedDate)
                DateSelectorRanged(selectedDate: selectedDate)
                    .frame(width: UIScreen.screenWidth - 10)
            }
        }
    }
}

struct Planner_Previews: PreviewProvider {
    static var previews: some View {
        Planner()
    }
}
