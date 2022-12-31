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
        
        assignment.activeHours = Int16(hours)
        assignment.activeMinutes = Int16(minutes)
        assignment.activeSeconds = Int16(seconds)
        
        assignment.status = status
        
        print("SAVING 1/2")

        do {
            try viewContext.save()
            print("SAVING 2/2")
        } catch {
            print(error.localizedDescription)
            print("Error")
        }
    }

    

    var body: some View {
        VStack {
            /// The Main Timer
            HStack {
                HStack(spacing: 0) {
                    Spacer().frame(width: 12)
                    Text("\(status) - ")
                    timerText(hours: hours, minutes: minutes, seconds: seconds, hoursStop: Int(assignment.hourStop), minutesStop: Int(assignment.minuteStop))
                    Spacer().frame(width: 12)
                }
                .frame(height: 40)
                .background(Color.yellow)
                .fixedSize()
                .cornerRadius(50)
                .font(.system(size: fontSize))
                .shadow(radius: 2)
                .padding(.leading)
                Spacer()
            }
            /// Buttons
            HStack {
                HStack {
                    Button(action:{
                        print("RESTART")
                        self.stopTimer()
                        self.resetTimer()
                        status = "To Do"
                        self.updateTime(assignment)
                    }){
                        Image(systemName: "arrow.counterclockwise")
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                            .background(Color.yellow)
                            .fixedSize()
                            .cornerRadius(50)
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                            .shadow(radius: 2)

                    }

                    Button(action:{
                        print("PAUSE/PLAY")
                        if timerIsPaused {
                            self.startTimer()
                        } else {
                            self.stopTimer()
                        }
                        self.updateTime(assignment)
                                                
                    }){
                        if timerIsPaused {
                            Image(systemName: "play.fill")
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                                .background(Color.yellow)
                                .fixedSize()
                                .cornerRadius(50)
                                .font(.system(size: fontSize))
                                .fontWeight(.bold)
                                .shadow(radius: 2)

                        } else {
                            Image(systemName: "pause.fill")
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                                .background(Color.yellow)
                                .fixedSize()
                                .cornerRadius(50)
                                .font(.system(size: fontSize))
                                .fontWeight(.bold)
                                .shadow(radius: 2)
                        }

                    }
                    Button(action:{
                        print("FINISHED")
                        self.stopTimer()
                        self.calculateTotal()
                        
                        if !isFinished {
                            isFinished = true
                        } else {
                            isFinished = false
                        }
                        
                        if isFinished {
                            status = "Finished!"
                        } else if hours * 3600 + minutes * 60 + seconds == 0  {
                            status = "To Do"
                        } else {
                            status = "In Progress"
                        }
                        
                        self.updateTime(assignment)
                        
                    }){
                        if status == "Finished!" {
                            Image(systemName: "checkmark.circle.fill")
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                                .background(Color.yellow)
                                .fixedSize()
                                .cornerRadius(50)
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .shadow(radius: 2)

                        } else {
                            Image(systemName: "checkmark.circle")
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                                .background(Color.yellow)
                                .fixedSize()
                                .cornerRadius(50)
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .shadow(radius: 2)

                        }

                    }
                    Button(action:{
                        print("ADD")
                        addTimeBool = true
                    }){
                        Image(systemName: "plus")
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                            .background(Color.yellow)
                            .fixedSize()
                            .cornerRadius(50)
                            .font(.system(size: fontSize))
                            .fontWeight(.bold)
                            .shadow(radius: 2)
                            /// Alert view to add hours and minutes
                            .alert("Add Time", isPresented: $addTimeBool, actions: {
                                TextField("Add Minutes", text: $addMinutes)
                                    .keyboardType(.decimalPad)
                                TextField("Add Hours", text: $addHours)
                                    .keyboardType(.decimalPad)

                                Button(action: {
                                    self.addTime()
                                    self.updateTime(assignment)
                                }) {
                                    Text("OK")
                                }
                                Button("Cancel", role: .cancel) {}
                            })

                    }
                }
                .padding(.leading)
                Spacer()
            }

            

        }
    }

    func startTimer(){
        timerIsPaused = false
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
            if self.seconds == 59 {
                self.seconds = 0
                if self.minutes == 59 {
                    self.minutes = 0
                    self.hours = self.hours + 1
                }
                else {
                    self.minutes = self.minutes + 1
                }
            }
            else {
              self.seconds = self.seconds + 1
            }
            if (hours * 60) + minutes >= (assignment.hourStop * 60) + assignment.minuteStop {
                overTime = true
            }
            
            if hours * 3600 + minutes * 60 + seconds == 0 {
                status = "To Do"
            } else if !isFinished {
                status = "In Progress"
            }

            // Every 10 seconds update
            
            if seconds % 10 == 0 {
                self.updateTime(assignment)
            }
             
            
        }
    }

    func stopTimer(){
        timerIsPaused = true
        timer?.invalidate()
        timer = nil
    }

    func resetTimer(){
        timerIsPaused = true
        hours = 0
        minutes = 0
        seconds = 0
        overTime = false
    }
    func calculateTotal() {
        timerIsPaused = true
        //Save to core data
    }
    func addTime() {
        hours += Int(addHours) ?? 0
        minutes += Int(addMinutes) ?? 0
        addHours = ""
        addMinutes = ""
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
