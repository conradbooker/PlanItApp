//
//  ExpandedAssignment.swift
//  PlanIt
//
//  Created by Conrad on 1/20/23.
//

import SwiftUI

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}


struct ExpandedAssignment: View {
    var assignment: Assignment
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
        
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
    //    @Binding private var showEnlarged: Bool
    
    private func findHeight(_ text: String) -> CGFloat {
        if Double(text.count) / 45 < 1.3 {
            return 81
        }
        return CGFloat((text.count / 45) * 17 + 81)
    }
    
    @State private var timerSize = CGSize()
    @State private var descriptionSize = CGSize()
    @State private var descriptionTitleSize = CGSize()

    var text: String = "Read sections 1-7 of \"Song of Myself\"--also, please read attached excerpts from his \"Preface\""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("cDarkGray")
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 15)
                            .shadow(radius: 3)
                            .foregroundColor(Color(red: CGFloat(assignment.red), green: CGFloat(assignment.green), blue: CGFloat(assignment.blue)))
                        
                        Spacer()
                            .frame(width: 5)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 3)
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text((assignment.course ?? "Error") + " - " +  (assignment.assignmentType ?? "#<NotFound @x08B38BA9>"))
                                        .font(.subheadline)
                                        .padding(.leading, 6)
                                    Spacer()
                                }
                                HStack {
                                    Text(assignment.title ?? "")
                                        .fontWeight(.medium)
                                        .padding(.leading, 6)
                                    Spacer()
                                }.padding(.top, 4)
                                HStack(spacing: 0) {
                                    Text("Due: ")
                                        .padding(.leading, 6)
                                        .font(.subheadline)
                                    Text((assignment.dueDate ?? Date()).formatted(.dateTime.weekday(.wide)) + ", ")
                                        .font(.subheadline)
                                    Text(assignment.dueDate ?? Date(), style: .date)
                                    
                                        .font(.subheadline)
                                    Spacer()
                                }.padding(.top, 4)
                                
                            }
                            
                        }
                        .frame(width: UIScreen.screenWidth * 5.5/6)
                        
                    }
                    .frame(width: UIScreen.screenWidth - 10, height: findHeight(assignment.title ?? ""))
                    
                    Spacer()
                        .frame(height: 5)
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color("cLessDarkGray"))
                            .shadow(radius: 3)
                        HStack {
                            TimerView(hours: Int(assignment.activeHours), minutes: Int(assignment.activeMinutes), seconds: Int(assignment.activeSeconds), status: assignment.status ?? "Error", isFinished: assignment.isFinished, assignment: assignment)
                                .environment(\.managedObjectContext, persistedContainer.viewContext)
                                .readSize { t in
                                    timerSize = t
                                }
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 6)
                    }
                    .frame(width: UIScreen.screenWidth - 16.2, height: timerSize.height + 8)

                    Spacer()
                        .frame(height: 5)

                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color("cLessDarkGray"))
                            .shadow(radius: 3)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Description:")
                                    .padding(.leading, 6)
                                    .readSize { size in
                                        descriptionTitleSize = size
                                    }
                                Spacer()
                            }.padding(.top, 4)
                            
                            HStack {
                                Text(assignment.summary ?? "No Description")
                                    .padding(.leading, 6)
                                    .readSize { size in
                                        descriptionSize = size
                                    }
                                Spacer()
                            }
                            .padding(.top, 4)
                            .padding(.bottom, 6)
                            Spacer()
                        }
                    }.frame(width: UIScreen.screenWidth - 16.2, height: 200)
                    Spacer()
                }
            }
        }.navigationTitle("Focus Mode")
    }
}

struct ExpandedAssignment_Previews: PreviewProvider {
    @Environment(\.managedObjectContext) static var viewContext
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        
        ExpandedAssignment(assignment: Assignment(context: viewContext))
            .environment(\.managedObjectContext, persistedContainer.viewContext)
//            .previewLayout(.fixed(width: 400, height: 250))
    }
}
