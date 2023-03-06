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

public class timerClass: ObservableObject {
    
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
    @Published var addTime: TimeInterval = 0

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
        totalAccumulatedTime = previouslyAccumulatedTime + Date().timeIntervalSince(startDate!) + addTime
//        print(totalAccumulatedTime)
    }
    
    func reset() {
        guard state == .paused else { return }
        previouslyAccumulatedTime = 0
        totalAccumulatedTime = 0
    }
}
