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
                if sourceURL.prefix(8) == "https://" {
                    loadJSonURL(sourceURL)
                } else {
                    sourceURL = "https://" + sourceURL
                    loadJSonURL(sourceURL)
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
