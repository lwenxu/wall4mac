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
    var uid: UUID? = UUID()
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
    
    @MainActor
    func downloadImage() async -> String? {
        do {
            let filePath = "/Users/lwen/Documents/wallpaper/test/\(id).jpg"
            if FileManager.default.fileExists(atPath: filePath) {
                return filePath
            }
            
            let (url,_) = try await URLSession.shared.download(for: URLRequest(url: URL(string: path)!))
            
            try FileManager.default.moveItem(atPath: url.path, toPath:filePath)
            return filePath
        }catch {
            print("download image fail !",error)
        }
        return nil
    }
    
}


class ImageItemModel : ObservableObject {
    @Published var imageItems:[ImageItem] = []
    @Published var imageMeta:ImageMeta = ImageMeta()
    
    @MainActor
    func fetchImages(_ sorting:String = "toplist",_ page:Int = 1 ) async {
        do {
            let url = URL(string: "https://wallhaven.cc/api/v1/search?sorting=\(sorting)&page=\(page)")!
            let (data,_) = try await URLSession.shared.data(from: url)
            var searchRs = try JSONDecoder().decode(ImageSearchRs.self, from: data)
            
            imageItems = self.addUUID(searchRs.data)
            imageMeta = searchRs.meta
            
        } catch {
            print("request image error!",error)
        }
    }
    
    
    @MainActor
    func fetchMoreImages(_ sorting:String = "date_added",_ page:Int = 1 ) async {
        do {
            let url = URL(string: "https://wallhaven.cc/api/v1/search?sorting=\(sorting)&page=\(page)")!
            let (data,_) = try await URLSession.shared.data(from: url)
            var searchRs = try JSONDecoder().decode(ImageSearchRs.self, from: data)
            
            imageItems += self.addUUID(searchRs.data)
            imageMeta = searchRs.meta
        } catch {
            print("request image error!")
        }
    }
    
    func addUUID( _ images: [ImageItem]) -> [ImageItem] {
        var res: [ImageItem] = []
        for var item in images {
            item.uid = UUID()
            res.append(item)
        }
        return res
    }
}
