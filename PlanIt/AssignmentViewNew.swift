//
//  AssignmentViewNew.swift
//  PlanIt
//
//  Created by Conrad on 1/7/23.
//

import SwiftUI

struct AssignmentViewNew: View {
    
    var assignment: Assignment
        
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
        
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>

    
    private func findHeight(_ text: String) -> CGFloat {
        if Double(text.count) / 45 < 1.5 {
            return 109
        }
        return CGFloat((text.count / 45) * 17 + 119)
    }
    
    var text: String = "Read sections 1-7 of \"Song of Myself\"--also, please read attached excerpts from his \"Preface\""
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 15, height: geometry.size.height)
                    .shadow(radius: 3)
                    .foregroundColor(Color(red: CGFloat(assignment.red),green: CGFloat(assignment.green),blue: CGFloat(assignment.blue)))
                Spacer()
                    .frame(width: 5)
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color("cLessDarkGray"))
                        .shadow(radius: 3)
                    VStack(alignment: .leading, spacing: 0) {
//                        Spacer()
                        HStack {
                            Text((assignment.course ?? "Error") + " - " +  (assignment.assignmentType ?? "#<NotFound @x08B38BA9>"))
                                .font(.subheadline)
                                .padding(.leading, 6)
                            Spacer()
                        }.padding(.top, 4)
                        HStack {
                            Text(assignment.title ?? "Error Title")
                                .fontWeight(.medium)
                                .padding(.leading, 6)
                            Spacer()
                        }.padding(.top, 4)
                        HStack(spacing: 0) {
                            Text("Due: ")
                                .padding(.leading, 6)
                                .font(.subheadline)
                            Text((assignment.due ?? Date()).formatted(.dateTime.weekday(.wide)) + ", ")
                                .font(.subheadline)
                            Text(assignment.due ?? Date(), style: .date)

                                .font(.subheadline)
                            Spacer()
                        }.padding(.top, 4)
                        
                        HStack {
                            Button(action: {
                                
                            }, label: {
                                Text("Start")
                                    .padding(5.0)
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                                    .shadow(radius: 2)
                                    .padding([.leading, .bottom], 6)
                            })
                            Spacer()
                        }.padding(.top, 4)

                        
                    }

                }
                .frame(width: geometry.size.width * 5.5/6, height: geometry.size.height)

            }
            .frame(width: geometry.size.width - 10, height: geometry.size.height - 10)
            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)

        }
        .frame(height: findHeight(assignment.title ?? ""))

    }
}

struct AssignmentViewNew_Previews: PreviewProvider {
    @Environment(\.managedObjectContext) static var viewContext

    static var previews: some View {
        
        let persistedContainer = CoreDataManager.shared.persistentContainer
        
        AssignmentViewNew(assignment: Assignment(context: viewContext))
            .environment(\.managedObjectContext, persistedContainer.viewContext)
            .previewLayout(.fixed(width: 400, height: 250))
    }
}
