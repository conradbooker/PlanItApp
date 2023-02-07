//
//  ChildAssignmentRow.swift
//  PlanIt
//
//  Created by Conrad on 1/16/23.
//

import SwiftUI

struct ChildAssignmentRow: View {
    @Binding var date: Date
    @Binding var hourStop: String
    @Binding var minuteStop: String
    var stopDate: Date
    
    var minute: String {
        if Int(minuteStop) ?? 0 == 1 {
            return "min"
        } else {
            return "mins"
        }

    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color("cLessDarkGray"))
                    .frame(width: geometry.size.width-10, height: 46)
                    .shadow(radius: 2)
                HStack(spacing: 0) {
                    NumTextField(subText: "h", text: $hourStop)
                        .frame(width: 40)
                        .textFieldStyle(.roundedBorder)
                        .padding(.leading, 2)
                        .padding(.trailing, 7.0)
                        .multilineTextAlignment(.center)
                    if Int(hourStop) ?? 0 == 1 {
                        Text("hour")
                    } else {
                        Text("hours")
                    }
                    NumTextField(subText: "m", text: $minuteStop)
                        .frame(width: 40)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 7.0)
                        .multilineTextAlignment(.center)
                    DatePicker(minute, selection: $date,in: ...stopDate, displayedComponents: [.date])
                }
                .frame(width: geometry.size.width-20)
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
        }
    }

}

struct ChildAssignmentRow_Previews: PreviewProvider {
    static var previews: some View {
        ChildAssignmentRow(date: .constant(Date()), hourStop: .constant("0"), minuteStop: .constant("0"), stopDate: Date())
    }
}
