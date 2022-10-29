//
//  ContentView.swift
//  wall4mac
//
//  Created by 徐鹏飞 on 2022/10/1.


import SwiftUI


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
    
    @ObservedObject var imageItemMode:ImageItemModel = ImageItemModel()
    
    var body: some View {
        HStack{
            
            VStack{
                List(navList){ item in
                    Label(item.name, systemImage:item.icon)
                        .frame(minWidth: 100,maxWidth: 200,alignment: .leading)
                        .foregroundStyle(.linearGradient(colors: [.red,.blue], startPoint: .leading, endPoint: .trailing))
                        .padding(5)
                        .background(currentNavItem == item.id ? .gray : .clear)
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
                        .tag(item.id)
                        
                }
                .frame(minWidth: 200 , maxWidth: 200,maxHeight: .infinity)
                .listStyle(.sidebar)
                .listRowInsets(EdgeInsets(top: 5, leading: 1, bottom: 5, trailing: 1))
                
                .background(.ultraThinMaterial)
                .task {
                    await imageItemMode.fetchImages()
                }
                
                Group{
                    Button{
                        pageNum = pageNum>1 ? pageNum-1 : pageNum
                        Task{
                            await imageItemMode.fetchImages(sorting,pageNum)
                        }
                    } label:{
                        Label("上一页", systemImage: "folder.badge.plus")
                    }
                    
                    Button{
                        pageNum = pageNum + 1
                        Task{
                            await imageItemMode.fetchImages(sorting,pageNum)
                        }
                    } label:{
                        Label("下一页", systemImage: "folder.badge.plus")
                    }
//                    Button(action: {
//
//                    }, label: Label("下一页"))
                }
            }.zIndex(1)
            
            
            ScrollView (.vertical) {
                LazyVGrid(columns: imageColumns, alignment: .leading , spacing: 10) {
                    
                    ForEach(imageItemMode.imageItems) { list in
                        AsyncImage(url: URL(string: list.thumbs.large!)) {image in
                            image.resizable()
                        } placeholder : {
                            ProgressView().frame(width: imageItemWidth)
                        }
                        .cornerRadius(10)
                        .padding(10)
                        .shadow(color: Color.gray, radius: 5, x:5 ,y:5)
                        .frame(width: 400)
                    }.listRowInsets(EdgeInsets())
                    
                }
            }
            .background(.ultraThinMaterial)
            .background(Image("wallhaven-bg"))
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
