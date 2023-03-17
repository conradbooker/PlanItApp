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
        case 430: return 20
        
        /// iPhone 14 Pro
        case 393: return 30
                        
        /// iPhone 13/12 Pro Max / 14 Plus
        case 428: return 20
        
        /// iPhone 12,12Pro,13,13Pro,14
        case 390: return 20
                
        /// iPhone 13/12 Mini/XS/X
        case 375: return 20
                
        /// iPhone 11/Pro/XS Max
        case 414: return 20
                                
        default: return 20
    }
}

struct test: View {
    @State var selectedTab: String = "Home"
    var body: some View {
        ZStack {
            switch selectedTab {
            case "Home": Home()
            case "Agenda": Checklist()
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
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: screenRadius())
                    .foregroundColor(Color("cDarkGray"))
                    .shadow(radius: 2)
                HStack {
                    Group {
                    Spacer()
                    TabBarButton(selectedTab: $selectedTab, imageName: "house", name: "Home")
                    Spacer()
                    TabBarButton(selectedTab: $selectedTab, imageName: "list.bullet.rectangle", name: "Agenda")
                    Spacer()
                    TabBarButton(selectedTab: $selectedTab, imageName: "plus.circle", name: "New")
                        // this should pop up
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

struct TabBarButton: View {
    @Binding var selectedTab: String
    var imageName: String
    var name: String
    
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
                if selectedTab == name {
                    RoundedRectangle(cornerRadius: 20)
                        .inset(by: 5)
                        .stroke(.secondary, lineWidth: 3)
                        .shadow(radius: 2)
                        .frame(width: 60, height: 60)
                } else {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color("cDarkGray"))
                }
                VStack {
                    Image(systemName: imageName + checkFilled())
                        .font(.title2)
                        .foregroundColor(.black)
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
