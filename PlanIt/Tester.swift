//
//  Tester.swift
//  PlanIt
//
//  Created by Conrad on 12/31/22.
//

import SwiftUI

struct Tester: View {
    @State var timeRemaining = 10
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text("\(timeRemaining)")
            .onReceive(timer) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
            }
    }
}


/*
 var parentID: String
 @State public var plannedDate: Date
 @State public var minuteStop: String
 @State public var hourStop: String
 var title: String
 var description: String
 var course: String

 */

//public class childAssignment: ObservableObject, Identifiable {
//    @Published public var amount: Int = 1
//    @Published public var plannedDate: Date = Date()
//    @Published public var minuteStop: String = "30"
//    @Published public var hourStop: String = "0"
//    @Published public var title: String = ""
//    @Published public var description: String = ""
//    @Published public var course: String = ""
//}

struct Tester_Previews: PreviewProvider {
    static var previews: some View {
        Tester()
    }
}
