//
//  TabBar.swift
//  PlanIt
//
//  Created by Conrad on 2/26/23.
//

import SwiftUI

struct test: View {
    @State var selectedTab: String = ""
    var body: some View {
        ZStack {
            switch selectedTab {
            case "Home": Home()
            case "Agenda": AgendaView()
            case "New": New() // should pop up
            case "Due": Due()
            case "Settings": Settings()
            default: Home()
            }
            TabBar(selectedTab: $selectedTab)
        }
    }
}

struct TabBar: View {
    @Binding var selectedTab: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.screenWidth - 12, height: 100)
            HStack {
                TabBarButton(selectedTab: $selectedTab, imageName: "", name: "Home")
                TabBarButton(selectedTab: $selectedTab, imageName: "", name: "Agenda")
                TabBarButton(selectedTab: $selectedTab, imageName: "", name: "New")
                    //implement button here
                TabBarButton(selectedTab: $selectedTab, imageName: "", name: "Due")
                TabBarButton(selectedTab: $selectedTab, imageName: "", name: "Settings")
            }
        }
    }
}

struct TabBarButton: View {
    @Binding var selectedTab: String
    var imageName: String
    var name: String

    var body: some View {
        Button {
            selectedTab = name
            print(selectedTab)
        } label: {
            Text(name)
        }
    }
}



struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
