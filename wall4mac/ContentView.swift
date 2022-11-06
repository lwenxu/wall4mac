//
//  ContentView.swift
//  wall4mac
//
//  Created by 徐鹏飞 on 2022/10/1.


import SwiftUI

import AppKit
//import Wallpaper
//import Tiercel


struct ImageAreaPreferenceKey : PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat){
        value = nextValue()
    }
}

struct ImageItemPreferenceKey : PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat){
        value = nextValue()
    }
}

struct ContentView: View {
    
    let navList = [
        NavItem(id: 1, name: "Latest", icon: "tray",sorting: "date_added"),
        NavItem(id: 2, name: "Hot", icon: "flame",sorting: "views"),
        NavItem(id: 3, name: "Toplist", icon: "list.number",sorting: "toplist")
    ]
    
    @State private var currentNavItem:Int = 1
    @State private var imageAreaWidth:CGFloat = 1
    @State private var imageItemWidth:CGFloat = 400
    @State private var imageColumns:[GridItem] = [GridItem(.flexible()),GridItem(.flexible())]
    
    @State private var pageNum:Int = 1
    @State private var sorting:String = "date_added"
    
    @State private var hoverImageIdx:String? = nil
    @State private var imageDetailModel:ImageItem? = nil
    @State private var imageDetailPath:String? = nil
    
    @ObservedObject var imageItemMode:ImageItemModel = ImageItemModel()
    
    func nav() -> some View {
        VStack{
            ForEach(navList) { item in
                
                Label {
                    
                    Text(item.name)
                        .font(.title2)
                        .lineLimit(1)
                        .padding(.leading, 10)
                    
                } icon: {
                    Image(systemName: item.icon)
                        .frame(width: 20.0, height: 20.0)
                        .symbolVariant(.fill)
                        .font(.title2)
                    
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
            .frame(minWidth: 200, maxWidth: 200, minHeight: 160, maxHeight: 160, alignment: .top)
            .background(.regularMaterial, in:RoundedRectangle(cornerRadius: 8,style: .continuous))
            .padding(.leading,15)
            .task {
                await imageItemMode.fetchImages()
            }
    }
    
    
    func pagnation() -> some View {
        VStack{
            
            Text("当前 \(imageItemMode.imageMeta.current_page) 页, 共 \(imageItemMode.imageMeta.last_page) 页").foregroundColor(.primary.opacity(0.4))
            
            HStack {
                Button{
                    pageNum = pageNum>1 ? pageNum-1 : pageNum
                    Task{
                        await imageItemMode.fetchImages(sorting,pageNum)
                    }
                } label:{
                    Image(systemName: "chevron.backward.2")
                    Text("上一页")
                }.focusable(false)
                    .disabled(pageNum<=1)
                
                Button{
                    pageNum = pageNum + 1
                    Task{
                        await imageItemMode.fetchImages(sorting,pageNum)
                    }
                } label:{
                    Text("下一页")
                    Image(systemName: "chevron.forward.2")
                }.focusable(false)
            }
        }.padding(20)
            .frame(minWidth: 200, maxWidth: 200, minHeight: 80, maxHeight: 80, alignment: .top)
            .background(.regularMaterial, in:RoundedRectangle(cornerRadius: 8,style: .continuous))
            .padding(.leading,15)
    }
    
    func imageList() -> some View{
        
        ScrollView (.vertical) {
            LazyVGrid(columns: imageColumns, alignment: .leading , spacing: 10) {
                
                ForEach(imageItemMode.imageItems) { list in
                    AsyncImage(url: URL(string: list.thumbs.large!)) {image in
                        image.resizable()
                    } placeholder : {
                        ProgressView().frame(width: imageItemWidth)
                    }
                    .overlay(alignment: .bottom, content: {
                        if hoverImageIdx == list.id {
                            HStack (alignment: .center, spacing: 5){
                                Image(systemName: "heart.fill")
                                    .foregroundColor(Color(hue: 1.0, saturation: 0.713, brightness: 0.835))
                                Text("\(list.favorites)")
                                
                                Image(systemName: "laptopcomputer")
                                    .foregroundColor(Color.blue)
                                Text(list.resolution)
                                
                                Image(systemName: "rectangle.3.group.fill")
                                    .foregroundColor(Color.orange)
                                Text(list.category)
                                
                            }
                            .frame(width: 400, height: 20, alignment: .bottom)
                            .background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius:3,style:.continuous))
                        }
                    })
                    .cornerRadius(10)
                    .padding(10)
                    .shadow(color: Color.gray, radius: 5, x:5 ,y:5)
                    .frame(width: 400)
                    .onHover(perform: { isHover in
                        withAnimation(.easeIn(duration: 0.3)) {
                            hoverImageIdx = isHover ? list.id : nil
                        }
                    })
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.3)){
                            imageDetailModel = list
                        }
                        Task{
                            let path = await list.downloadImage()
                            imageDetailPath = path
                        }
                    }
                }.listRowInsets(EdgeInsets())
                
            }
        }
        
        .frame(minWidth: imageItemWidth * 2 + 100 , maxWidth: 9999)
        .overlay{
            GeometryReader{ proxy in
                Color.clear.preference(key: ImageAreaPreferenceKey.self,value: proxy.size.width)
            }
        }.onPreferenceChange(ImageAreaPreferenceKey.self){ value in
            withAnimation{
                imageAreaWidth = value
                
                let cols =  Int(floorf(Float(imageAreaWidth / imageItemWidth)))
                
                // 如果计算出来的 column 有变化，则更新 VGrid 的列数
                if cols == imageColumns.count{
                    return
                }
                var columns:[GridItem] = []
                for _ in 1...cols {
                    columns.append(GridItem(.flexible()))
                }
                if columns.count > 0 {
                    imageColumns  = columns;
                }
            }
        }
        
        
    }
    
    func imageDetailView() -> some View {
        
        VStack{
            
            
            AsyncImage(url: URL(string: (imageDetailModel?.path)!)) {image in
                
                HStack{
                    Spacer()
                    
                    Image(systemName: "square.and.arrow.down.on.square.fill")
                        .font(.title2)
                        .foregroundColor(Color.blue)
                        .onTapGesture {
                            guard let path = imageDetailPath else {
                                return
                            }
                            try? Wallpaper.set(URL(fileURLWithPath: imageDetailPath!))
                        }
                    
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color.red)
                        .onTapGesture {
                            imageDetailModel = nil
                            imageDetailPath = nil
                        }
                }
                image.resizable().scaledToFit()
               
            } placeholder : {
                ProgressView().frame(width: imageItemWidth)
            }
        }
        .frame(maxWidth: imageAreaWidth - 100,maxHeight: .infinity)
    }
    
    func backgroundBlur() -> some View{
        Color.clear.background(.ultraThinMaterial)
    }
    
    var body: some View {
        HStack {
            
            VStack (spacing: 20){
                
                nav()
                
                pagnation()
                
                Spacer()
                
            }.padding(.top,20)
                .padding(.bottom , 20)
                .padding(.leading,5)
            
            ZStack {
                imageList()
                
                if imageDetailModel != nil {
                    backgroundBlur()
                    imageDetailView()
                }
            }
            
        }
        .background(.ultraThinMaterial)
//        .background(Image("bg-\(Int.random(in: 1...6))")
        .background(Image("bg-6").resizable().scaledToFill())
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
