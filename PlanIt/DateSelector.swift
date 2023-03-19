//
//  DateSelector.swift
//  PlanIt
//
//  Created by Conrad on 1/22/23.
//

import SwiftUI

struct DateSelector: View {
    
    // MARK: Variables
    @Binding var selectedDate: Date
    @AppStorage("accentColor") var accentColor: String = "aMint"

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
                VStack(spacing: 0) {
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .labelsHidden()
//                    Spacer().frame(height:5)
                }
                RoundedRectangle(cornerRadius: 100)
                    .fill(Color("cLessDarkGray"))
                    .allowsHitTesting(false)
                    .shadow(radius: 2)
                HStack {
                    Button {
                        print("subtracted 1")
                        subtract()
                        impactMedium.impactOccurred()
                    } label: {
                        Image(systemName: "chevron.backward.circle.fill")
                            .font(.system(size: 20))
                    }
                    .padding(.leading, 8.0)
                    .buttonStyle(CircleButton(color: Color(accentColor)))
                    Spacer()
                    ZStack {
                        HStack(spacing: 0) {
                            Text(selectedDate.formatted(.dateTime.weekday(.wide)) + ", ")
                            Text(selectedDate, style: .date)
                        }
                        .allowsHitTesting(false)
                    }
                    Spacer()
                    Button {
                        print("added 1")
                        add()
                        impactMedium.impactOccurred()
                    } label: {
                        Image(systemName: "chevron.forward.circle.fill")
                            .font(.system(size: 20))
                    }
                    .padding(.trailing, 8.0)
                    .buttonStyle(CircleButton(color: Color(accentColor)))
                }
            }
            .frame(width: UIScreen.screenWidth-40, height:50)
        }
    }
}

struct CircleButton: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding(5.0)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(100)
            .shadow(radius: 2)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
    }
}


struct DateSelector_Previews: PreviewProvider {
    static var previews: some View {
        DateSelector(selectedDate: .constant(Date()))
    }
}
