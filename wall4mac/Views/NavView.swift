//
//  NavView.swift
//  wall4mac
//
//  Created by lwen on 2022/11/5.
//

import SwiftUI

struct NavView: View {
    
    let navList = [
        NavItem(id: 1, name: "Latest", icon: "tray",sorting: "date_added"),
        NavItem(id: 2, name: "Hot", icon: "flame",sorting: "views"),
        NavItem(id: 3, name: "Toplist", icon: "list.number",sorting: "toplist")
    ]
    
    var body: some View {
       
        VStack{
            ForEach(navList) { item in

                Label {
                    Text(item.name)
                        .font(.title2)
                        .lineLimit(1)
                    
                } icon: {
                    Image(systemName: item.icon)
                        .frame(width: 20.0, height: 20.0)
                        .symbolVariant(.fill)
                        .font(.body.bold())
                       
                }.frame(minWidth: 100,maxWidth: 200,alignment: .leading)
                    .foregroundStyle(currentNavItem == item.id
                                     ? .linearGradient(colors: [.red,.blue], startPoint: .leading, endPoint: .trailing)
                                     : .linearGradient(colors: [.primary.opacity(0.7)], startPoint: .leading, endPoint: .leading)
                    )
                    .padding(5)
                    .onTapGesture {
                        pageNum = 1
                        sorting = item.sorting
                        
                        Task{
                            await imageItemMode.fetchImages(item.sorting,pageNum)
                        }
                        
                        withAnimation{
                            currentNavItem = item.id
                        }
                    }
            }
        }.padding(20)
            .background(.regularMaterial, in:RoundedRectangle(cornerRadius: 8,style: .continuous))
        
    }
}

struct NavView_Previews: PreviewProvider {
    static var previews: some View {
        NavView()
    }
}
