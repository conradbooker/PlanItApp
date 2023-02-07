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

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var isFinished: Bool = false
    
    @State var startButtonDisabled: Bool = false
        
    @State var showTimerText: Bool = false
    
    var isStarted: Bool {
        if hours * 3600 + minutes * 60 + seconds == 0 || status == "To Do" {
            return false
        }
        return true
    }
    @State var isStarted1: Bool = false
    
    @State var forceStart: Bool = false
    
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

    init(assignment: Assignment) {
        self.assignment = assignment
        
        self.hours = Int(assignment.activeSeconds)/3600
        self.minutes = Int(assignment.activeSeconds)/60
        self.seconds = Int(assignment.activeSeconds)
        self.status = assignment.status ?? "To Do"
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
        self.changeStatus()
        self.updateTime(assignment)
    }
    private func start() {
        forceStart = true
        isStarted1 = true
        status = "In Progress"
        successHaptics()
        startButtonDisabled = true
        
        do {
            assignment.status = status
            try viewContext.save()
            print("startSave")
            
        } catch {
            print(error.localizedDescription)
            print("Error")
        }
    }
    
    private func playPause() {
        do {
            assignment.isPaused.toggle()
            try viewContext.save()
            print("pause/play")
        } catch {
            print(error.localizedDescription)
            print("Error")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            /// The Main Timer
//            if !isFinished {
                if !isStarted && !isStarted1 && status == "To Do" {
                    HStack(spacing: 0) {
                        Text("\(status) - ")
                        FormattedTime(secondStop: Int(assignment.secondStop))
                            .font(.system(size: 18))
                        Spacer()
                    }
                    .padding(.bottom, 4)
                    
                    HStack {
                        if !assignment.isFinished {
                            Button("Start") {
                                playPause()
                                start()
                                print("START")
                            }
                            .buttonStyle(TimerButton(color: Color("timerStart")))
                            .disabled(startButtonDisabled)
                        }
                        Button(action: {
                            done()
                            do {
                                assignment.isPaused = true
                                try viewContext.save()
                                print("pause/play")
                            } catch {
                                print(error.localizedDescription)
                                print("Error")
                            }

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
                    if !isFinished && showTimerText {
                        HStack(spacing: 0) {
                            Text("\(status) - ")
                            timerText(secondsStop: Int(assignment.secondStop), seconds: Int(assignment.activeSeconds))
                                .font(.system(size: 18))
                            Spacer()
                        }
                        .padding(.bottom, 4)
                    }
                    HStack {
                        if !assignment.isFinished {
                            if assignment.isPaused {
                                Button("Continue") {
                                    mediumHaptics()
                                    playPause()
                                    forceStart = true
                                    print("CONTINUE")
                                }
                                .buttonStyle(TimerButton(color: Color("timerPause")))
                            } else {
                                Button(action: {
                                    mediumHaptics()
                                    playPause()
                                    forceStart = false
                                    print("PAUSE")
                                }) {
                                    Text("Pause")
                                }
                                .buttonStyle(TimerButton(color: Color("timerPause")))
                            }
                            Button("Restart") {
                                successHaptics()
                                self.resetTimer()
                                forceStart = false
                                playPause()
                                self.status = "To Do"
                                self.updateTime(assignment)
                                self.startButtonDisabled = false
                                do {
                                    assignment.isPaused = true
                                    try viewContext.save()
                                    print("pause/play")
                                } catch {
                                    print(error.localizedDescription)
                                    print("Error")
                                }
                                print("RESTART")
                            }
                            .buttonStyle(TimerButton(color: Color("timerStop")))
                            
                            Button("Add Time") {
                                playPause()
                                forceStart = false
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
                                    playPause()
                                    forceStart = true
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
                            do {
                                assignment.isPaused = true
                                try viewContext.save()
                                print("pause/play")
                            } catch {
                                print(error.localizedDescription)
                                print("Error")
                            }

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
        // MARK: Timer portion
        }
        .padding(.leading, 6)
    }

    private func resetTimer() {
        isStarted1 = false
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
    
    private func timeString(accumulatedTime: TimeInterval) -> String {
        let hours = Int(accumulatedTime) / 3600
        let minutes = Int(accumulatedTime) / 60 % 60
        let seconds = Int(accumulatedTime) % 60
        
        let hourStop = Int(assignment.secondStop) / 3600
        let minuteStop = Int(assignment.secondStop) / 60 % 60
        let secondStop = Int(assignment.secondStop) % 60


        return String(format:"%02i:%02i:%02i", hours, minutes, seconds) + String(format:"%02i:%02i:%02i", hourStop, minuteStop, secondStop)
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
