//
//  TimerView.swift
//  PlanIt
//
//  Created by Conrad on 12/24/22.
//

import SwiftUI

func successHaptics() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}
func errorHaptics() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.error)
}
func mediumHaptics() {
    let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    rigidImpact.impactOccurred()
}

var timer = timerClass()

struct TimerView: View {
    
    @AppStorage("currentAssignmentID") var currentAssignmentID: String = ""
    
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
    
    @State var fontSize: CGFloat = 20

    let count = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
    @State var startButtonDisabled: Bool = false
            
    init(assignment: Assignment) {
        self.assignment = assignment
        
        self.hours = Int(assignment.activeSeconds)/3600
        self.minutes = Int(assignment.activeSeconds)/60
        self.seconds = Int(assignment.activeSeconds)
        
    }
    
    var isStarted: Bool {
        if hours * 3600 + minutes * 60 + seconds == 0 && assignment.status == "To Do" {
            return false
        }
        return true
    }
        
    @Environment(\.managedObjectContext) private var viewContext
    var assignment: Assignment
    
    private func updateTime() {
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
            print("Error")
        }
    }
    
    private func changeStatus() {
        if !assignment.isFinished {
            assignment.isFinished = true
            assignment.status = "Finished!"
            print("finished")
        } else {
            assignment.isFinished = false
            if !isStarted {
                assignment.status = "In Progress"
                print("in progress")
            } else {
                assignment.status = "To Do"
                print("to do")
            }
        }
    }

    private func done() {
//        print(status)
//        if assignment.isFinished
        self.changeStatus()
        do {
            assignment.isPaused = true
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    private func start() {
        assignment.status = "In Progress"
        successHaptics()
        startButtonDisabled = true
        
        if Int(timer.totalAccumulatedTime) != 0 {
            timer = timerClass()
        }
        
        timer.startTimer()
        
        do {
            try viewContext.save()
            print("startSave")
            
        } catch {
            print(error.localizedDescription)
            print("Error")
        }
    }
    
    
    private func pause() {
        let curr = Int64(timer.totalAccumulatedTime)
        timer.pauseTimer()
        do {
            assignment.activeSeconds = curr
            assignment.isPaused = true
            try viewContext.save()
            print("paused")
        } catch {
            print(error.localizedDescription)
            print("pause")
        }
    }
    
    private func play() {
        currentAssignmentID = assignment.assignmentID!
        timer = timerClass()
        timer.addTime = TimeInterval(assignment.activeSeconds)
        timer.startTimer()
        do {
            assignment.isPaused = false
            try viewContext.save()
            print("play")
        } catch {
            print(error.localizedDescription)
            print("Error")
        }

    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            /// The Main Timer
            // MARK: Not Started
            
            
            
            if !isStarted {
                // MARK: Start Text
                HStack(spacing: 0) {
                    Text("\(assignment.status ?? "To Do") - ")
                    FormattedTime(secondStop: Int(assignment.secondStop))
                        .font(.system(size: 18))
                    Spacer()
                }
                .padding(.bottom, 4)
                // MARK: Start Button
                HStack {
                    if !assignment.isFinished {
                        Button("Start") {
                            play()
                            start()
                            print("START")
                        }
                        .buttonStyle(TimerButton(color: Color("timerStart")))
                        .disabled(startButtonDisabled)
                    }
                    Button(action: {
                        done()
                        successHaptics()
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
            }
            // MARK: Timer Started
            
            
            
            else {
                // MARK: Timer Text
                if !assignment.isFinished {
                    HStack(spacing: 0) {
                        Text("\(assignment.status ?? "hi") - ")
                        Text(timeString(accumulatedTime: assignment.activeSeconds))
                            .font(.system(size: 18))
                        Spacer()
                    }
                    .padding(.bottom, 4)
                }
                HStack {
                    if !assignment.isFinished {
                        // MARK: Continue Button
                        if assignment.isPaused {
                            Button("Continue") {
                                mediumHaptics()
                                play()
                                print("CONTINUE")
                            }
                            .buttonStyle(TimerButton(color: Color("timerPause")))
                        }
                        // MARK: Pause Button
                        else {
                            Button(action: {
                                mediumHaptics()
                                pause()
                                print("PAUSE")
                            }) {
                                Text("Pause")
                            }
                            .buttonStyle(TimerButton(color: Color("timerPause")))
                        }
                        // MARK: Restart Button
                        Button("Restart") {
                            resetTimer()
                        }
                        .buttonStyle(TimerButton(color: Color("timerStop")))
                        
                        // MARK: Add Time Button
                        Button("Add Time") {
                            pause()
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
                                play()
                                self.addTime()
                                self.updateTime()
                            }) {
                                Text("OK")
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                    // MARK: Done Button
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
                } /// end of HStack
                
            } /// end of else
        // MARK: Timer portion
        }
//        .onChange(of: timer.totalAccumulatedTime) { _ in
//            if assignment.assignmentID == currentAssignmentID {
//                if !assignment.isPaused {
//                    assignment.activeSeconds = Int64(timer.totalAccumulatedTime)
//                    print("totalaccumulatedtime: \(timer.totalAccumulatedTime)")
//                    if assignment.activeSeconds >= assignment.secondStop {
//                        overTime = true
//                    }
//                    do {
//                        try viewContext.save()
//                        print("SAVED TIME")
//                    } catch {
//                        print(error.localizedDescription)
//                        print("Error")
//                    }
//                }
//            }
//        }
        .onAppear {
            print("current status now: " + (assignment.status ?? "-----"))
        }
        .onReceive(count) { _ in
            if assignment.assignmentID == currentAssignmentID {
                if !assignment.isPaused {
                    assignment.activeSeconds = Int64(timer.totalAccumulatedTime)
                    print("totalaccumulatedtime: \(timer.totalAccumulatedTime)")
                    if assignment.activeSeconds >= assignment.secondStop {
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
            } else {

                do {
                    assignment.isPaused = true
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }

            }
        }
        .padding(.leading, 6)
    }

    private func resetTimer() {
        successHaptics()
        pause()
        assignment.status = "To Do"
        do {
            assignment.isPaused = true
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
            print("Error")
        }
        print("RESTART")

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
        assignment.activeSeconds += Int64(Int(addHours)! * 3600 + Int(addMinutes)! * 60)
//        Int(Int(addHours)! * 3600) + Int(Int(addMinutes)! * 60)))
        addHours = ""
        addMinutes = ""
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
            print("Error")
        }
    }
    
    private func timeString(accumulatedTime: Int64) -> String {
        let hours = Int(accumulatedTime) / 3600
        let minutes = Int(accumulatedTime) / 60 % 60
        let seconds = Int(accumulatedTime) % 60
        
        let hourStop = Int(assignment.secondStop) / 3600
        let minuteStop = Int(assignment.secondStop) / 60 % 60
        let secondStop = Int(assignment.secondStop) % 60

        if hours < 1 {
            return String(format:"%02i:%02i", minutes, seconds) + " / " +  String(format:"%02i:%02i", minuteStop, secondStop)
        }

        return String(format:"%02i:%02i:%02i", hours, minutes, seconds) + " / " +  String(format:"%02i:%02i:%02i", hourStop, minuteStop, secondStop)
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

struct DayButton: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding(5.0)
            .background(color)
            .cornerRadius(4)
            .shadow(radius: 2)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
    }
}

struct timerText: View {
        
    var secondsStop: Int
    var seconds: Int
    
    var hourStop = 0
    var minutesStop = 0
    
    var minutes = 0
    var hours = 0
    
    init(secondsStop: Int, seconds: Int) {
        self.hourStop = secondsStop / 3600
        self.minutesStop = secondsStop / 60 % 60
        self.hours = seconds / 3600
        self.minutes = seconds / 60 % 60
        self.secondsStop = secondsStop
        self.seconds = seconds
    }
    
//    let hours = Int(accumulatedTime) / 3600
//    let minutes = Int(accumulatedTime) / 60 % 60
//    let seconds = Int(accumulatedTime) % 60


    var body: some View {
        if hourStop == 0 {
            if seconds < 10 {
                Text("\(minutes):0\(seconds) / \(minutesStop):00")
            } else {
                Text("\(minutes):\(seconds) / \(minutesStop):00")
            }
        } else {
            if minutes < 10 {
                if seconds < 10 {
                    Text("\(hours):0\(minutes):0\(seconds) / \(hourStop):\(minutesStop):00")
                } else {
                    Text("\(hours):0\(minutes):\(seconds) / \(hourStop):\(minutesStop):00")
                }
            } else {
                if seconds < 10 {
                    Text("\(hours):\(minutes):0\(seconds) / \(hourStop):\(minutesStop):00")
                } else {
                    Text("\(hours):\(minutes):\(seconds) / \(hourStop):\(minutesStop):00")
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
        
        TimerView(assignment: assignment)
            .environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
