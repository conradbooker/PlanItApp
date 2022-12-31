//
//  Tester.swift
//  PlanIt
//
//  Created by Conrad on 12/31/22.
//

import SwiftUI

struct Tester: View {
    var individualOnlineAssignment: IndividualOnlineAssignmets
    var body: some View {
        Text(individualOnlineAssignment.SUMMARY)
    }
}

struct Tester_Previews: PreviewProvider {
    static var previews: some View {
        Tester(individualOnlineAssignment: onlineAssignmentData[0].VCALENDAR[0].VEVENT[0])
    }
}
