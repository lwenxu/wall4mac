//
//  ImageItem.swift
//  wall4mac
//
//  Created by 徐鹏飞 on 2022/10/27.
//

import Foundation

struct ImageSearchRs : Decodable {
    var data:[ImageItem]
    var meta:ImageMeta
}

struct ImageMeta : Decodable {
    var current_page:Int = 0
    var last_page:Int = 0
    var per_page:Int = 0
    var total:Int = 0
    var query:String?
    var seed:String?
}

struct ImageItem : Identifiable , Decodable {
    var id:String
    var url:String
    var short_url:String
    var views:Int
    var favorites: Int
    var source:String
    var purity:String
    var category:String
    var dimension_x:Int
    var dimension_y:Int
    var resolution:String
    var ratio:String
    var file_size:Int
    var file_type:String
    var created_at:String
    var colors: [String]
    var path:String
    var thumbs:ImageThumb
    
    struct ImageThumb : Decodable {
        var large:String?
        var original:String?
        var small:String?
    }
}


class ImageItemModel : ObservableObject {
    @Published var imageItems:[ImageItem] = []
    @Published var imageMeta:ImageMeta = ImageMeta()
    
    @MainActor
    func fetchImages() async {
        do {
            let url = URL(string: "https://wallhaven.cc/api/v1/search")!
            let (data,_) = try await URLSession.shared.data(from: url)
            let searchRs = try JSONDecoder().decode(ImageSearchRs.self, from: data)
            imageItems = searchRs.data
            imageMeta = searchRs.meta
        } catch {
            print("request image error!")
        }
    }
}
