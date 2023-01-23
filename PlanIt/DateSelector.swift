//
//  DateSelector.swift
//  PlanIt
//
//  Created by Conrad on 1/22/23.
//

import SwiftUI

struct DateSelector: View {
    
    // MARK: Variables
    @State var currentDate: Date = Date()
    @Binding var selectedDate: Date

    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    let calendar = Calendar.current
        
    func add() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
    }
    func subtract() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
    }
    
    var body: some View {
        VStack {
            ZStack {
                ZStack {
                    VStack(spacing: 0) {
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        Spacer().frame(height:5)
                    }
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("cLessDarkGray"))
                        .frame(width: UIScreen.screenWidth - 12, height:50)
                        .allowsHitTesting(false)
                        .shadow(radius: 2)
                    HStack(spacing: 0) {
                        Text(selectedDate.formatted(.dateTime.weekday(.wide)) + ", ")
                        Text(selectedDate, style: .date)
                    }
                    .allowsHitTesting(false)

                }
                HStack {
                    Button(action:{
                        print("subtracted 1")
                        subtract()
                        impactMedium.impactOccurred()
                    }){
                        Image(systemName: "minus.circle.fill")
                    }
                    Spacer().frame(width: UIScreen.screenWidth - 100)
                    Button(action:{
                        print("added 1")
                        add()
                        impactMedium.impactOccurred()
                    }){
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
    }
}

struct DateSelector_Previews: PreviewProvider {
    static var previews: some View {
        DateSelector(selectedDate: .constant(Date()))
    }
}
