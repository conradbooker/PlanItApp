//
//  Due.swift
//  PlanIt
//
//  Created by Conrad on 12/24/22.
//

import SwiftUI

struct Item: Identifiable {
    var id: Int
    var title: String
    var color: Color
    var date: Date
}

class Store: ObservableObject {
    @Published var items: [Item]
    
    let colors: [Color] = [.red, .orange, .blue, .teal, .mint, .green, .gray, .indigo, .black]
    

    // dummy data
    init() {
        items = []
        for i in 0...7 {
            let new = Item(id: i, title: "Item \(i)", color: colors[i], date: Date())
            items.append(new)
        }
    }
}


struct Due: View {
    
    @StateObject var store = Store()
    @State private var snappedItem = 0.0
    @State private var draggingItem = 0.0
    @State private var touches = 0
    @State private var relativeRotations = 0
    
    var body: some View {
        
        VStack {
            ZStack {
                ForEach(store.items) { item in
                    
                    // article view
                    ZStack {
                        RoundedRectangle(cornerRadius: 100)
                            .fill(item.color)
                            .frame(width: 300,height:100)
                        VStack {
                            Text(item.title)
                                .padding()
                            Text(String(item.date.formatted(.dateTime.day().month().year())))
                        }
                    }
                    .frame(width: 400, height: 200)
                    
                    .scaleEffect(1.0 - abs(distance(item.id)) * 0.2 )
    //                .opacity(1.0 - abs(distance(item.id)) * 0.3 )
                    .offset(x: myXOffset(item.id), y: 0)
                    .zIndex(1.0 - abs(distance(item.id)) * 0.1)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        draggingItem = snappedItem + value.translation.width / 100
                    }
                    .onEnded { value in
                        withAnimation {
                            draggingItem = snappedItem + value.predictedEndTranslation.width / 100
                            draggingItem = round(draggingItem).remainder(dividingBy: Double(store.items.count))
                            let temp = draggingItem
                            snappedItem = draggingItem
                            
                            if draggingItem < 0 {
                                relativeRotations += Int(abs(temp) - abs(draggingItem))
                            } else {
                                relativeRotations -= Int(abs(temp) - abs(draggingItem))
                            }
                            
                            touches += 1
                            
                        }
                    }
            )
            Text("Touches: \(touches)")
            Text("Relative Rotations: \(relativeRotations)")
            Text("snappedItem: \(snappedItem)")
            Text("draggingItem: \(draggingItem)")

        }
        
    }
    
    func distance(_ item: Int) -> Double {
        return (draggingItem - Double(item)).remainder(dividingBy: Double(store.items.count))
    }
    
    func myXOffset(_ item: Int) -> Double {
        let angle = Double.pi * 2 / Double(store.items.count) * distance(item)
        return sin(angle) * 200
    }
    
}

struct Due_Previews: PreviewProvider {
    static var previews: some View {
        Due()
    }
}
