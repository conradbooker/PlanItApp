//
//  ExternalSource.swift
//  PlanIt
//
//  Created by Conrad on 12/29/22.
//

import SwiftUI

struct ExternalSource: View {
    
    @State private var saveDisabled: Bool = true
    @State private var showErrorText: Bool = false
    @AppStorage("sourceURL") var sourceURL: String = ""
    var mySchoolAppSchoolList: [String] = ["Trinity Schhol NYC","Dalton"]
    
    var body: some View {
        VStack {
            Text("This app supports only 'Schoology', or Blackbaud's 'myschoolapp' for homework assignments. If you do not use either of these services, please go to [this form] for help.")
                .padding()
            TextField("Link", text: $sourceURL)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .onChange(of: sourceURL) { _ in
                    if sourceURL == "" { saveDisabled = true }
                    else { saveDisabled = false }
                }
            Button("Save") {
                if sourceURL.contains("cal") || sourceURL.contains("iCal") || sourceURL.contains("ical") || sourceURL.contains(".ics") || sourceURL.contains("ics") || sourceURL == "" {
                    if sourceURL.contains("https://") && !sourceURL.contains("webcal://") {
                        loadJSonURL()
                    } else if sourceURL.contains("webcal://") {
                        sourceURL = sourceURL.replacingOccurrences(of: "webcal://", with: "")
                        loadJSonURL()
                    } else {
                        sourceURL = "https://" + sourceURL
                        loadJSonURL()
                    }
                } else {
                    showErrorText = true
                }
            }.disabled(saveDisabled)
            
            if showErrorText {
                Text("Error, not a valid URL. If this is a valid URL, click this button. If this is not a propper url, this will crash the app.")
                    .padding()
            }
        }
    }
}

struct ExternalSource_Previews: PreviewProvider {
    static var previews: some View {
        ExternalSource()
    }
}
