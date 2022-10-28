//
//  ContentView.swift
//  wall4mac
//
//  Created by 徐鹏飞 on 2022/10/1.
//uy7

import SwiftUI

struct ContentView: View {
    
    let navList = [
        NavItem(id: 1, name: "Latest", icon: "tray"),
        NavItem(id: 2, name: "Hot", icon: "flame"),
        NavItem(id: 3, name: "Toplist", icon: "list.number")
    ]
    
    @State private var currentNavItem:Int = 1
    
    @ObservedObject var imageItemMode:ImageItemModel = ImageItemModel()
    
    var body: some View {
        HStack{
            
            List(navList){ item in
                Label(item.name, systemImage:item.icon)
                    .frame(minWidth: 100,maxWidth: 200,alignment: .leading)
                    .padding(5)
                    .background(currentNavItem == item.id ? .teal : .clear)
                    .background(in:  RoundedRectangle(cornerRadius: 8) )
                    .onTapGesture {
                        currentNavItem = item.id
                    }
            }
            .frame(minWidth: 100,maxWidth: 200,maxHeight: .infinity)
            .listStyle(.sidebar)
            .background(.ultraThinMaterial)
            .task {
                await imageItemMode.fetchImages()
            }
            
            
            LazyHGrid(rows: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(imageItemMode.imageItems) { list in
                    AsyncImage(url: URL(string: list.thumbs.large!)).frame(minWidth:300)
                }
            }  
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
