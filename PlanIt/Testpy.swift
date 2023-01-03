//
//  Testpy.swift
//  PlanIt
//
//  Created by Conrad on 12/31/22.
//

import SwiftUI
//import Network

struct Testpy: View {
    
    let URL = "https://trinityschoolnyc.myschoolapp.com/podium/feed/iCal.aspx?z=HdbCT3ZaWBaxtYaG0jy3COOOHSIw9SwPejVt1ZiRL0e%2f1LkExSAan453LoSYfB4QMIeAjRyRcFPyvvRbCsQ7QA%3d%3d"
        
    var body: some View {
        VStack {
            Text(String("\(runPythonICSJSon(URL))"))
        }
    }
}

struct Testpy_Previews: PreviewProvider {
    static var previews: some View {
        Testpy()
    }
}
