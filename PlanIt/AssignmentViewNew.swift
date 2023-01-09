//
//  AssignmentViewNew.swift
//  PlanIt
//
//  Created by Conrad on 1/7/23.
//

import SwiftUI

struct AssignmentViewNew: View {
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 15, height: geometry.size.height * 9.3/10)
                    .shadow(radius: 3)
                    .foregroundColor(.red)
                Spacer()
                    .frame(width: 5)
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                    VStack(spacing: 0) {
                        HStack {
                            Text("American History A - Homework")
                                .padding(.leading, 6)
                            Spacer()
                        }.padding(.top, 4)
                        HStack {
                            Text("Read sections 1-7 of \"Song of Myself\"--also, please read attached excerpts from his \"Preface\"")
                                .font(.system(size: 22))
                                .padding(.leading, 6)
                            Spacer()
                        }.padding(.top, 4)
                        HStack {
                            Text("Due Monday, January 9th")
                                .padding(.leading, 6)
                            Spacer()
                        }.padding(.top, 4)
                        Spacer()
                    }

                }
                .frame(width: geometry.size.width * 5.5/6, height: geometry.size.height * 9.3/10)

            }
            .frame(width: geometry.size.width - 10, height: geometry.size.height - 10)
            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)

        }

    }
}

struct AssignmentViewNew_Previews: PreviewProvider {
    static var previews: some View {
        AssignmentViewNew()
            .previewLayout(.fixed(width: 400, height: 90))
        // height bassed off of if assignment title length / 35 < 0, one line, otherwise new line idk

    }
}
