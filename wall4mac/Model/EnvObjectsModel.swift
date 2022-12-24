//
//  EnvObjectsModel.swift
//  wall4mac
//
//  Created by lwen on 2022/11/19.
//

import Foundation


class EnvObjectsModel:ObservableObject{
    @Published var showDetail:Bool = false
    @Published var imageList:[ImageItem] = []
}
