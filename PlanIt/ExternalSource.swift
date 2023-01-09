//
//  ExternalSource.swift
//  PlanIt
//
//  Created by Conrad on 12/29/22.
//

import SwiftUI

struct ExternalSource: View {
    
    @State private var saveDisabled: Bool = true
    @AppStorage("sourceURL") var sourceURL: String = ""
    var individualOnlineAssignment: IndividualOnlineAssignmets
    
    var body: some View {
        VStack {
            TextField("Link", text: $sourceURL)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .onChange(of: sourceURL) { _ in
                    if sourceURL == "" { saveDisabled = true }
                    else { saveDisabled = false }
                }
            Button("Save") {
                if sourceURL.contains("https://") && !sourceURL.contains("webcal://") {
                    loadJSonURL()
                } else if sourceURL.contains("webcal://") {
                    sourceURL = sourceURL.replacingOccurrences(of: "webcal://", with: "")
                    loadJSonURL()
                } else {
                    sourceURL = "https://" + sourceURL
                    loadJSonURL()
                }
            }.disabled(saveDisabled)
            
            Text(individualOnlineAssignment.SUMMARY)

        }
    }
}

struct ExternalSource_Previews: PreviewProvider {
    static var previews: some View {
        ExternalSource(individualOnlineAssignment: onlineAssignmentData[0].VCALENDAR[0].VEVENT[46])
    }
}
