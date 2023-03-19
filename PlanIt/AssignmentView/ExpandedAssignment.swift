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
    
    @State private var timerSize = CGSize()
    @State private var descriptionSize = CGSize()
    @State private var descriptionTitleSize = CGSize()

    @State private var courseSize = CGSize()
    @State private var titleSize = CGSize()
    @State private var dueDateSize = CGSize()
    
    var text: String = "Read sections 1-7 of \"Song of Myself\"--also, please read attached excerpts from his \"Preface\""
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack {
                    HStack {
                        Text("Description:")
                            .padding(.leading, 6)
                        Spacer()
                    }
                    .padding(.top, 4)
                    .opacity(0)
                    .readSize { size in
                        descriptionTitleSize = size
                    }
                    
                    HStack {
                        Text(assignment.summary ?? "No Description")
                            .padding(.leading, 6)
                        Spacer()
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 6)
                    .readSize { size in
                        descriptionSize = size
                    }
                    .opacity(0)
                    Color("cDarkGray")
                        .ignoresSafeArea()
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: 15, height: courseSize.height + titleSize.height + dueDateSize.height)
                                .shadow(radius: 3)
                                .foregroundColor(Color(red: CGFloat(assignment.red), green: CGFloat(assignment.green), blue: CGFloat(assignment.blue)))
                            
                            Spacer()
                                .frame(width: 5)
                            
                            ZStack {
                                HStack {
                                    Text(assignment.title ?? "")
                                        .fontWeight(.medium)
                                        .padding(.leading, 6)
                                    Spacer()
                                }
                                .readSize { size in
                                    titleSize = size
                                }
                                .opacity(0)
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color("cLessDarkGray"))
                                    .shadow(radius: 3)
                                    .frame(height: courseSize.height + titleSize.height + dueDateSize.height)
                                VStack(alignment: .leading, spacing: 0) {
                                    
                                    // MARK: course
                                    HStack {
                                        Text((assignment.course ?? "Error") + " - " +  (assignment.assignmentType ?? "#<NotFound @x08B38BA9>"))
                                            .font(.subheadline)
                                            .padding(.leading, 6)
                                        Spacer()
                                    }
                                    .padding(.top, 4)
                                    .readSize { size in
                                        courseSize = size
                                    }
                                    
                                    // MARK: title
                                    HStack {
                                        Text(assignment.title ?? "")
                                            .fontWeight(.medium)
                                            .padding(.leading, 6)
                                        Spacer()
                                    }.padding(.top, 4)
                                    
                                    // MARK: due date
                                    HStack(spacing: 0) {
                                        Text("Due: ")
                                            .padding(.leading, 6)
                                            .font(.subheadline)
                                        Text((assignment.dueDate ?? Date()).formatted(.dateTime.weekday(.wide)) + ", ")
                                            .font(.subheadline)
                                        Text(assignment.dueDate ?? Date(), style: .date)
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    .padding(.top, 4)
                                    .padding(.bottom, 6)
                                    .readSize { size in
                                        dueDateSize = size
                                    }
                                    
                                }
                                
                            }
                            .frame(width: UIScreen.screenWidth * 5.5/6)
                            
                        }
                        .frame(width: UIScreen.screenWidth - 10)
                        
                        Spacer()
                            .frame(height: 5)
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 3)
                            HStack {
                                TimerView(assignment: assignment)
                                    .environment(\.managedObjectContext, persistedContainer.viewContext)
                                    .readSize { size in
                                        timerSize = size
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
                                    Spacer()
                                }
                                .padding(.top, 4)
                                HStack {
                                    Text(assignment.summary ?? "No Description")
                                        .padding(.leading, 6)
                                    Spacer()
                                }
                                .padding(.top, 4)
                                Spacer()
                            }
                        }.frame(width: UIScreen.screenWidth - 16.2, height: descriptionSize.height + descriptionTitleSize.height + 8)
                        Spacer()
                    }
                }
            }
        }.navigationTitle("Expanded Assignment".lower())
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
