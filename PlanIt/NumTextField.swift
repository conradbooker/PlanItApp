//
//  NumTextField.swift
//  PlanIt
//
//  Created by Conrad on 1/17/23.
//

import SwiftUI

struct NumTextField: View {
    @State private var showAlert: Bool = false
    var subText: String
    @Binding var text: String
    
    var body: some View {
        TextField(subText, text: $text)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("please numbers only!!"))
            }
            .onChange(of: text) { _ in
                if !text.isNumeric && text != "" {
                    text = ""
                    showAlert.toggle()
                }
            }
    }
}

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}

struct NumTextField_Previews: PreviewProvider {
    static var previews: some View {
        NumTextField(subText: "h", text: .constant("people"))
    }
}
