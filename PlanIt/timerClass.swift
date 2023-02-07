//
//  TimerClass.swift
//  PlanIt
//
//  Created by Conrad on 1/24/23.
//

import Foundation
import CoreData
import SwiftUI

var disableTimerWhenNotActive = false

var timerData: Data = Data()

//struct TimerDict: Codable, Identifiable {
//    var id: UUID
//    var timer: timerClass
//}

//func load(_ uuid: UUID) -> timerClass {
////    guard let timerArray = try? JSONDecoder().decode(TimerArray.self, from: timerData) else { return }
//    guard let timers = try? JSONDecoder().decode(TimerDict.self, from: timerData) else { return }
//    
//}
//
//func upload(_ uuid: UUID) {
//    let timer = timerClass()
//    let timers = TimerDict(id: uuid, timer: timer)
//}

var timer = timerClass()

public func switchTimers() {
    
}

public class timerClass: ObservableObject {
    
//    required init(coder aDecoder: NSCoder) {
//        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
//        image = aDecoder.decodeObject(forKey: "image") as? String ?? ""
//    }
//
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(name, forKey: "name")
//        aCoder.encode(image, forKey: "image")
//    }

//    override init() {
//        super.init()
//    }
//
//    public func encode(with coder: NSCoder) {
//        coder.encode(timer, forKey: "timer")
//        coder.encode(previouslyAccumulatedTime, forKey: "previouslyAccumulatedTime")
//        coder.encode(startDate, forKey: "startDate")
//        coder.encode(lastStopDate, forKey: "lastStopDate")
//        coder.encode(state, forKey: "state")
//        coder.encode(totalAccumulatedTime, forKey: "totalAccumulatedTime")
//    }
//
//    public required init?(coder aDecoder: NSCoder) {
//        timer = aDecoder.decodeObject(forKey: "timer") as! Timer?
//        previouslyAccumulatedTime = aDecoder.decodeObject(forKey: "previouslyAccumulatedTime") as! TimeInterval? ?? 0
//        startDate = aDecoder.decodeObject(forKey: "startDate") as! Date?
//        lastStopDate = aDecoder.decodeObject(forKey: "lastStopDate") as! Date?
//        state = aDecoder.decodeObject(forKey: "state") as! timerMode? ?? .paused
//        totalAccumulatedTime = aDecoder.decodeObject(forKey: "totalAccumulatedTime") as! TimeInterval? ?? 0
//        super.init()
//    }
    
    // every 10 seconds save to coredata

    
//    public required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        previouslyAccumulatedTime = try values.decode(TimeInterval.self, forKey: .previouslyAccumulatedTime)
//        startDate = try values.decode(Date.self, forKey: .startDate)
//        lastStopDate = try values.decode(Date.self, forKey: .lastStopDate)
//        state = try values.decode(timerMode.self, forKey: .state)
//        totalAccumulatedTime = try values.decode(TimeInterval.self, forKey: .totalAccumulatedTime)
//    }
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(previouslyAccumulatedTime, forKey: .previouslyAccumulatedTime)
//        try container.encode(startDate, forKey: .startDate)
//        try container.encode(lastStopDate, forKey: .lastStopDate)
//        try container.encode(lastStopDate, forKey: .lastStopDate)
//        try container.encode(state, forKey: .state)
//        try container.encode(totalAccumulatedTime, forKey: .totalAccumulatedTime)
//    }
    
//    init(timer: Timer?) {
//        self.timer = timer
//    }
    
    private enum CodingKeys: String, CodingKey {
        case previouslyAccumulatedTime
        case startDate
        case lastStopDate
        case state
        case totalAccumulatedTime
    }
    
    private enum timerMode: String {
        case paused
        case running
        case suspended
    }
    
    private weak var timer: Timer?
    
    private var previouslyAccumulatedTime: TimeInterval = 0
    private var startDate: Date? = nil
    private var lastStopDate: Date? = nil
    private var state: timerMode = .paused

    @Published var totalAccumulatedTime: TimeInterval = 0

    var isSuspended: Bool { return state == .suspended }
    var isRunning: Bool { return state == .running }
    var isPaused: Bool { return state == .paused }
    
    private func pause() {
        let accumulatedRunningTime = Date().timeIntervalSince(startDate!)

        previouslyAccumulatedTime += accumulatedRunningTime
        totalAccumulatedTime = previouslyAccumulatedTime

        lastStopDate = Date()
        timer!.invalidate()
        timer = nil
    }
    func pauseTimer() {
        if state == .running {
            pause()
            state = .paused
            print("pause timer")
        }
    }
    func suspendTimer() {
        if state == .running {
            pause()
            state = .suspended
        }
    }
    
    func startTimer() {
        if state != .running {
            startDate = Date()
            if state == .suspended && !disableTimerWhenNotActive {
                startDate = lastStopDate
            }
            // schedule a new timer
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(update)), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode:RunLoop.Mode.default)
            state = .running
        }
    }
    
    @objc private func update() {
        totalAccumulatedTime = previouslyAccumulatedTime + Date().timeIntervalSince(startDate!)
    }
    
    func reset() {
        guard state == .paused else { return }
        previouslyAccumulatedTime = 0
        totalAccumulatedTime = 0
    }
}
