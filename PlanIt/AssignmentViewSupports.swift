//
//  AssignmentViewSupports.swift
//  PlanIt
//
//  Created by Conrad on 1/18/23.
//

import SwiftUI

struct AssignmentViewSupports: View {
    var body: some View {
        Text("Hello, World!")
    }
}
extension UIScreen {
   static let screenWidth = CGFloat(UIScreen.main.bounds.size.width)
   static let screenHeight = CGFloat(UIScreen.main.bounds.size.height)
//   static let screenSize = CGFloat(UIScreen.main.bounds.size)
}

struct FormattedTime: View {
    var hourStop: Int
    var minuteStop: Int
    var body: some View {
        if hourStop == 0 {
            Text("\(String(minuteStop)) mins")
        } else {
            if hourStop > 1 {
                Text("\(hourStop) hours \(String(minuteStop)) mins")
            } else {
                Text("\(hourStop) hour \(String(minuteStop)) mins")
            }
        }
    }
}

struct AssignmentViewSupports_Previews: PreviewProvider {
    static var previews: some View {
        FormattedTime(hourStop: 0, minuteStop: 10)
    }
}
