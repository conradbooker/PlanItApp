//
//  ExternalSource.swift
//  PlanIt
//
//  Created by Conrad on 12/29/22.
//

import SwiftUI

struct ExternalSource: View {
    
    @State private var sourceURL: String = ""
    @State private var saveDisabled: Bool = true

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
                    // save
                } else {
                    sourceURL = "https://" + sourceURL
                }
            }.disabled(saveDisabled)

        }
    }
}

struct ExternalSource_Previews: PreviewProvider {
    static var previews: some View {
        ExternalSource()
    }
}
