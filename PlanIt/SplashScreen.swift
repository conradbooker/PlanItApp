//
//  SplashScreen.swift
//  PlanIt
//
//  Created by Conrad on 3/19/23.
//

import SwiftUI

struct SplashScreen: View {
    @State var isActive: Bool = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var done: Bool = false
    @AppStorage("name") var name: String = "new user"
    @AppStorage("onBoarding") var onBoarded: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    // Customise your SplashScreen here
    var body: some View {
        if isActive {
            if onBoarded {
                ContentView()
                    .environment(\.managedObjectContext, persistedContainer.viewContext)
            } else {
                OnboardingView(done: $done).environment(\.managedObjectContext, persistedContainer.viewContext)
            }
        } else {
            ZStack {
                Color("cDarkGray")
                    .ignoresSafeArea()
                VStack {
                    VStack {
                        Image("PlanItIcon")
                            .resizable()
                            .frame(width: 200, height: 200)
                        
                        Text("Welcome \(name)!".lower())
                            .font(.title)
                            .fontWeight(.heavy)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 0.9
                            self.opacity = 1.00
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
