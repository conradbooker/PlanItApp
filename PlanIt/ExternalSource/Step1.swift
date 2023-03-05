//
//  Step1.swift
//  PlanIt
//
//  Created by Conrad on 3/4/23.
//

import SwiftUI

struct Step1: View {
    
    @AppStorage("sourceURL") var sourceURL: String = ""
    @State private var saveDisabled: Bool = false
    @State private var showErrorText: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                /// Video
                Rectangle()
                    .frame(width: UIScreen.screenWidth-100, height: (UIScreen.screenWidth-100)*3/4)
                    .padding(.vertical)
                Text("Please type in the link to your school calendar here. Please note that PlanIt app supports \"myschoolapp\" and \"schoology\" right now. Invalid URLs may crash PlanIt.".lower())
                    .padding(.horizontal,12)
                TextField("Link".lower(), text: $sourceURL)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal,12)
                    .onChange(of: sourceURL) { _ in
                        if sourceURL == "" { saveDisabled = true }
                        else { saveDisabled = false }
                    }
                Button {
                    if sourceURL.contains("https://") && !sourceURL.contains("webcal://") {
                        loadJSonURL()
                    } else if sourceURL.contains("webcal://") {
                        sourceURL = sourceURL.replacingOccurrences(of: "webcal://", with: "")
                        sourceURL = "https://" + sourceURL
                        loadJSonURL()
                    } else {
                        sourceURL = "https://" + sourceURL
                        loadJSonURL()
                    }
                } label: {
                    Text("Next Step")
                }
                
                Spacer()
            }
            .navigationTitle("Sync Step 1/3".lower())
        }
    }
}

struct Step1_Previews: PreviewProvider {
    static var previews: some View {
        Step1()
    }
}
