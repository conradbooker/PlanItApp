//
//  CourseRow.swift
//  PlanIt
//
//  Created by Conrad on 3/5/23.
//

import SwiftUI

struct CourseRow: View {
    var course: Course
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
            
    @State private var showEdit: Bool = false
    @State private var courseSize = CGSize()
    @State private var titleSize = CGSize()
    @State private var dueDateSize = CGSize()
    @State private var offset = CGFloat()
    
    @State private var showDeleteButton: Bool = false
    @State private var toggled: Bool = false
    @State private var toggled2: Bool = false
    @State private var revert: Bool = false
    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    
    private func deleteCourse(_ course: Course) {
        withAnimation(.easeOut) { viewContext.delete(course) }
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 15, height: courseSize.height + titleSize.height + dueDateSize.height + 10)
                    .shadow(radius: 3)
                    .foregroundColor(Color(red: CGFloat(course.red), green: CGFloat(course.green), blue: CGFloat(course.blue)))
                
                Spacer()
                    .frame(width: 5)
                
                ZStack {
                    HStack {
                        Text(course.title ?? "")
                            .fontWeight(.medium)
                            .padding(.leading, 6)
                        Spacer()
                    }
                    .padding(.top, 4)
                    .readSize { size in
                        titleSize = size
                    }
                    .opacity(0)
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color("cLessDarkGray"))
                        .shadow(radius: 3)
                        .frame(height: courseSize.height + titleSize.height + 10)
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // MARK: course
                        HStack {
                            // MARK: title
                            HStack {
                                Text(course.title ?? "Error nothing loaded")
                                    .fontWeight(.medium)
                                    .padding(.leading, 6)
                                Spacer()
                            }
                            .padding(.top, 4)
                            .padding(.bottom, 6)
                            Spacer()
                        }
                    }
                    
                }
                .frame(width: UIScreen.screenWidth * 5.5/6)
                
            }
            .offset(x: offset, y: 0)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 && gesture.translation.width > -20 {
                            if gesture.translation.width <= -15 {
                                impactMedium.impactOccurred()
                            }
                            offset = gesture.translation.width
                            print(gesture.translation)
                        } else if gesture.translation.width > 0 && showDeleteButton {
                            revert = true
                            withAnimation(.easeOut) { showDeleteButton = false }
                        }
                        
                    }
                    .onEnded { _ in
                        if offset <= -15 && !revert {
                            print("doing")
                            let count = 1...500
                            withAnimation(.easeIn) { showDeleteButton = true }
                            for _ in count {
                                withAnimation(.easeIn(duration: 0.1)) {
                                    if offset > -50 { offset -= 1 }
                                }
//                                impactMedium.impactOccurred()
                            }
                            // remove the card
                        } else if offset > -15 && !revert {
                            withAnimation(.easeOut) { showDeleteButton = false }
                            offset = .zero
                            toggled = false
                        } else if revert {
                            withAnimation(.easeOut) { showDeleteButton = false }
                            withAnimation(.easeIn(duration: 0.1)) { offset = .zero }
                            toggled = false
                            revert = false
                        }
                    }
            )
            .frame(width: UIScreen.screenWidth - 10)
            if showDeleteButton {
                Button {
                    deleteCourse(course)
                    successHaptics()
                } label: {
                    Image(systemName: "trash")
                        .font(.title2)
                }
                .padding(.leading, -38)
            }
        }
    }
}

struct CourseRow_Previews: PreviewProvider {
    @Environment(\.managedObjectContext) static var viewContext
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        CourseRow(course: Course(context: viewContext))
    }
}
