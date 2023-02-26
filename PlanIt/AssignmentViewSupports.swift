//
//  AssignmentViewSupports.swift
//  PlanIt
//
//  Created by Conrad on 1/18/23.
//

import SwiftUI

extension UIScreen {
   static let screenWidth = CGFloat(UIScreen.main.bounds.size.width)
   static let screenHeight = CGFloat(UIScreen.main.bounds.size.height)
//   static let screenSize = CGFloat(UIScreen.main.bounds.size)
}

struct FormattedTime: View {
    
    var hourStop: Int = 0
    var minuteStop: Int = 0
    var secondStop: Int
    
    init(secondStop: Int) {
        let t = Int(secondStop)
        self.secondStop = secondStop
        self.hourStop = t / 3600
        self.minuteStop = t / 60 % 60
        if self.minuteStop >= 60 {
            self.hourStop = t / 60
            self.minuteStop = t % 60
        }
    }
    
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
        FormattedTime(secondStop: 0)
    }
}

struct Checkbox: ButtonStyle {
    var color: Color
    @State var isPressed: Bool = false
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
