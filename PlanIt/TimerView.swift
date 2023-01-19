//
//  TimerView.swift
//  PlanIt
//
//  Created by Conrad on 12/24/22.
//

import SwiftUI

struct TimerView: View {
    
    @State var hours: Int = 0
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    
    @State var hoursOT: Int = 0
    @State var minutesOT: Int = 0
    @State var secondsOT: Int = 0

    @State var timerIsPaused: Bool = true
    @State var overTime: Bool = false
    
    @State var addTimeBool: Bool = false
    @State var addMinutes: String = ""
    @State var addHours: String = ""

    @State var status: String = "To Do"
    
    @State var fontSize: CGFloat = 20

    @State var timer: Timer? = nil
    
    @State var isFinished: Bool = false
    
    @State var isDisabled: Bool = false
    
    @State var justStarted: Bool = true
    
    func successHaptics() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    func resetHaptics() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    func mediumHaptics() {
        let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
        rigidImpact.impactOccurred()
    }

    var isStarted: Bool {
        if hours * 3600 + minutes * 60 + seconds == 0 || status == "To Do" {
            return false
        }
        return true
    }
    @State var isStarted1: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    var assignment: Assignment
    
//    init() {
//        status = assignment.status ?? "To Do"
//        hours = Int(assignment.activeHours)
//        minutes = Int(assignment.activeMinutes)
//        seconds = Int(assignment.activeSeconds)
//        isFinished = assignment.isFinished
//    }
//
//    init

    init(hours: Int, minutes: Int, seconds: Int, status: String, isFinished: Bool, assignment: Assignment) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.status = status
        self.isFinished = isFinished
        self.assignment = assignment
        
        self.status = assignment.status ?? "To Do"
        self.hours = Int(assignment.activeHours)
        self.minutes = Int(assignment.activeMinutes)
        self.seconds = Int(assignment.activeSeconds)
        self.isFinished = assignment.isFinished

        
    }
    
    private func updateTime(_ assignment: Assignment) {
        
        assignment.status = status
        
        assignment.isFinished = isFinished
        
        print("SAVING 1/2")

        do {
            try viewContext.save()
            print("SAVING 2/2")
        } catch {
            print(error.localizedDescription)
            print("Error")
        }
    }
    
    private func changeStatus() {
        if !isFinished {
            isFinished = true
            status = "Finished!"
        } else {
            isFinished = false
            if !isStarted {
                status = "To Do"
            } else {
                status = "In Progress"
            }
        }
    }

    private func done() {
        self.stopTimer()
        self.changeStatus()
        self.updateTime(assignment)
    }
    private func changeTimerStatus() {
        if !isStarted {
            isStarted1 = true
            status = "In Progress"
        } else {
            isStarted1 = false
            status = "To Do"
        }
        assignment.status = status
        
        assignment.isFinished = isFinished
        
        print("starting time")
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
            print("Error")
        }

    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            /// The Main Timer
//            if !isFinished {
                if !isStarted && !isStarted1 && status == "To Do"{
                    HStack(spacing: 0) {
                        Text("\(status) - ")
                        FormattedTime(hourStop: Int(assignment.hourStop), minuteStop: Int(assignment.minuteStop))
                            .font(.system(size: 18))
                        Spacer()
                    }
                    .padding(.bottom, 4)
                    
                    HStack {
                        if !assignment.isFinished {
                            Button("Start") {
                                timerIsPaused = false
                                justStarted = true
                                self.changeTimerStatus()
                                self.startTimer()
                                self.successHaptics()
                                self.isDisabled = true
                                print("START")
                            }
                            .buttonStyle(TimerButton(color: Color("timerStart")))
                            .disabled(isDisabled)
                        }
                        Button(action: {
                            done()
                            successHaptics()
                            print("DONE")
                        }) {
                            if !assignment.isFinished {
                                Image(systemName: "square")
                                    .font(.system(size: 18))
                            } else {
                                Image(systemName: "checkmark.square.fill")
                                    .font(.system(size: 18))
                            }
                        }
                        .buttonStyle(TimerButton(color: Color("timerDone")))
                        
                        Spacer()
                    }
                } else {
                    HStack(spacing: 0) {
                        Text("\(status) - ")
                        timerText(hours: Int(assignment.activeHours), minutes: Int(assignment.activeMinutes), seconds: Int(assignment.activeSeconds), hoursStop: Int(assignment.hourStop), minutesStop: Int(assignment.minuteStop))
                            .font(.system(size: 18))
                        Spacer()
                    }
                    .padding(.bottom, 4)
                    
                    HStack {
                        if !assignment.isFinished {
                            if timerIsPaused && !justStarted {
                                Button("Continue") {
                                    mediumHaptics()
                                    self.startTimer()
                                    timerIsPaused = false
                                    print("CONTINUE")
                                }
                                .buttonStyle(TimerButton(color: Color("timerPause")))
                            } else {
                                Button(action: {
                                    self.stopTimer()
                                    mediumHaptics()
                                    timerIsPaused = false
                                    print("PAUSE")
                                    justStarted = false
                                }) {
                                    Text("Pause")
                                }
                                .buttonStyle(TimerButton(color: Color("timerPause")))
                            }
                            Button("Restart") {
                                self.stopTimer()
                                self.resetTimer()
                                timerIsPaused = true
                                self.status = "To Do"
                                self.updateTime(assignment)
                                self.isDisabled = false
                                print("RESTART")
                            }
                            .buttonStyle(TimerButton(color: Color("timerStop")))
                            
                            Button("Add Time") {
                                timerIsPaused = true
                                mediumHaptics()
                                addTimeBool = true
                            }
                            .buttonStyle(TimerButton(color: Color("timerAddTime")))
                            .alert("Add Time", isPresented: $addTimeBool) {
                                TextField("Add Minutes", text: $addMinutes)
                                    .keyboardType(.decimalPad)
                                TextField("Add Hours", text: $addHours)
                                    .keyboardType(.decimalPad)
                                
                                Button(action: {
                                    timerIsPaused = false
                                    self.addTime()
                                    self.updateTime(assignment)
                                }) {
                                    Text("OK")
                                }
                                Button("Cancel", role: .cancel) {}
                            }
                        }
                        Button(action: {
                            successHaptics()
                            done()
                        }) {
                            if !assignment.isFinished {
                                Image(systemName: "square")
                            } else {
                                Image(systemName: "checkmark.square.fill")
                            }
                        }
                        .buttonStyle(TimerButton(color: Color("timerDone")))
                        Spacer()
                    }
                    
                }
//            }
            
        }
        .padding(.leading, 6)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { tempTimer in
            print("timing")
            if assignment.activeSeconds == 59 {
                assignment.activeSeconds = 0
                if assignment.activeMinutes == 59 {
                    assignment.activeMinutes = 0
                    assignment.activeHours = assignment.activeHours + 1
                }
                else {
                    assignment.activeMinutes = assignment.activeMinutes + 1
                }
            }
            else {
                assignment.activeSeconds = assignment.activeSeconds + 1
            }
            if (assignment.activeHours * 60) + assignment.activeMinutes >= (assignment.hourStop * 60) + assignment.minuteStop {
                overTime = true
            }
            do {
                try viewContext.save()
                print("SAVED TIME")
            } catch {
                print(error.localizedDescription)
                print("Error")
            }

        }
    }

    private func stopTimer(){
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer(){
        isStarted1 = false
        assignment.activeHours = 0
        assignment.activeMinutes = 0
        assignment.activeSeconds = 0
        do {
            try viewContext.save()
            print("SAVING 2/2")
        } catch {
            print(error.localizedDescription)
            print("Error")
        }
    }
    private func addTime() {
        hours += Int(addHours) ?? 0
        minutes += Int(addMinutes) ?? 0
        addHours = ""
        addMinutes = ""
    }
}

struct TimerButton: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding(5.0)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(4)
            .shadow(radius: 2)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
    }
}

struct timerText: View {
    
    var hours: Int
    var minutes: Int
    var seconds: Int
    var hoursStop: Int
    var minutesStop: Int

    var body: some View {
        if hoursStop == 0 {
            if seconds < 10 {
                Text("\(minutes):0\(seconds) / \(minutesStop):00")
            } else {
                Text("\(minutes):\(seconds) / \(minutesStop):00")
            }
        } else {
            if minutes < 10 {
                if seconds < 10 {
                    Text("\(hours):0\(minutes):0\(seconds) / \(hoursStop):\(minutesStop):00")
                } else {
                    Text("\(hours):0\(minutes):\(seconds) / \(hoursStop):\(minutesStop):00")
                }
            } else {
                if seconds < 10 {
                    Text("\(hours):\(minutes):0\(seconds) / \(hoursStop):\(minutesStop):00")
                } else {
                    Text("\(hours):\(minutes):\(seconds) / \(hoursStop):\(minutesStop):00")
                }
            }
        }

    }
}

struct TimerView_Previews: PreviewProvider {
    @Environment(\.managedObjectContext) static var viewContext

    static var previews: some View {
        
        let persistedContainer = CoreDataManager.shared.persistentContainer
        
        let assignment = Assignment(context: viewContext)
        
        TimerView(hours: Int(assignment.activeHours), minutes: Int(assignment.activeMinutes), seconds: Int(assignment.activeSeconds), status: assignment.status ?? "Error", isFinished: assignment.isFinished, assignment: assignment)
            .environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
