//
//  TimerTransformer.swift
//  PlanIt
//
//  Created by Conrad on 1/27/23.
//

import Foundation

class TimerTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let timer = value as? timerClass else { return nil }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: timer, requiringSecureCoding: true)
            return data
        } catch {
            return nil
        }
        
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }

        do {
            let timer = try NSKeyedUnarchiver.unarchivedObject(ofClass: timerClass.self, from: data)
            return timer
        } catch {
            return nil
        }
    }
    
}
