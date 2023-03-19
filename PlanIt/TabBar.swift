//
//  TabBar.swift
//  PlanIt
//
//  Created by Conrad on 2/26/23.
//

import SwiftUI

func screenRadius() -> CGFloat {
    let currentScreenWidth = Int(UIScreen.screenWidth)
    switch currentScreenWidth {
        /// iPhone 14 Pro Max
        case 430: return 30
        
        /// iPhone 14 Pro
        case 393: return 30
                        
        /// iPhone 13/12 Pro Max / 14 Plus
        case 428: return 20
        
        /// iPhone 12,12Pro,13,13Pro,14
        case 390: return 20
                
        /// iPhone 13/12 Mini/XS/X
        case 375: return 30
                
        /// iPhone 11/Pro/XS Max
        case 414: return 20
                                
        default: return 30
    }
}

struct test: View {
    @State var selectedTab: String = "Home"
    @State var showSheet: Bool = false
    @State var selectedDate: Date = Date()

    var body: some View {
        ZStack {
            switch selectedTab {
            case "Home": Home(selectedDate: selectedDate)
            case "Agenda": Checklist(selectedDate: selectedDate)
            case "Due": Due(selectedDate: selectedDate)
            case "Settings": Settings()
            default: Home(selectedDate: selectedDate)
            }
            TabBar(selectedTab: $selectedTab, showSheet: $showSheet, selectedDate: $selectedDate)
        }
        .sheet(isPresented: $showSheet) {
            New(isPresented: .constant(true))
        }
    }
}

struct TabBar: View {
    @Binding var selectedTab: String
    @Binding var showSheet: Bool
    @Binding var selectedDate: Date
    @AppStorage("accentColor") var accentColor: String = "aMint"

    var body: some View {
        VStack {
            Spacer()
            if ["Home","Due","Agenda"].contains(selectedTab) {
                DateSelector(selectedDate: $selectedDate)
            }
            ZStack {
                RoundedRectangle(cornerRadius: screenRadius())
                    .foregroundColor(Color("cLessDarkGray"))
                    .shadow(radius: 2)
                HStack {
                    Group {
                    Spacer()
                    TabBarButton(selectedTab: $selectedTab, imageName: "house", name: "Home")
                    Spacer()
                    TabBarButton(selectedTab: $selectedTab, imageName: "list.bullet.rectangle", name: "Agenda")
                        Spacer()
                        Spacer()
                    PopUp(showSheet: $showSheet, imageName: "plus.circle.fill", name: "New")
                        // this should pop up
                        Spacer()
                    }
                    Spacer()
                    //implement button here
                    TabBarButton(selectedTab: $selectedTab, imageName: "exclamationmark.triangle", name: "Due")
                    Spacer()
                    TabBarButton(selectedTab: $selectedTab, imageName: "gearshape.2", name: "Settings")
                    Spacer()
                }
            }
            .frame(width: UIScreen.screenWidth - 40, height: 80)
            Spacer().frame(height: 20)
        }
        .ignoresSafeArea()
    }
}

struct PopUp: View {
    @Binding var showSheet: Bool
    var imageName: String
    var name: String
    @AppStorage("accentColor") var accentColor: String = "aMint"
    
    var body: some View {
        Button {
            showSheet = true
            mediumHaptics()
        } label: {
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
        .buttonStyle(CircleButton(color: Color(accentColor)))
    }
}

struct TabBarButton: View {
    @Binding var selectedTab: String
    var imageName: String
    var name: String
    @AppStorage("accentColor") var accentColor: String = "aMint"
    
    private func checkFilled() -> String {
        if selectedTab == name {
            return ".fill"
        }
        return ""
    }

    var body: some View {
        Button {
            selectedTab = name
            print(selectedTab)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color("cLessDarkGray"))
                VStack {
                    RoundedRectangle(cornerRadius: 200)
                        .frame(width: 15,height:4)
                        .foregroundColor(Color("cLessDarkGray"))
                    Image(systemName: imageName + checkFilled())
                        .font(.title2)
                        .foregroundColor(Color("bw"))
                    Spacer().frame(height: 5)
                    if selectedTab == name {
                        RoundedRectangle(cornerRadius: 200)
                            .frame(width: 20,height:4)
                            .shadow(radius: 2)
                            .foregroundColor(Color(accentColor))
                    } else {
                        RoundedRectangle(cornerRadius: 200)
                            .frame(width: 0,height:4)
                            .foregroundColor(Color("cLessDarkGray"))
                    }
//                    Text(name)
//                        .font(.subheadline)
                }
            }
        }
    }
}



struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
