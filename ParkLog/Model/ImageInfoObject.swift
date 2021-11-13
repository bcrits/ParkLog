//
//  ImageInfoObject.swift
//  ParkLog
//
//  Created by admin on 11/3/21.
//

import Foundation

public struct ImageInfoObject: Codable {
    let url: URL
    let index: Int
    var downloadLocation: URL?
    var isDownloaded: Bool = false
    
    private enum CodingKeys: CodingKey {
        case url
    }
    
    init(url: URL, index: Int) {
        self.url = url
        self.index = index
    }
    
    init(url: URL, index: Int, downloadLocation: URL) {
        self.url = url
        self.index = index
        self.downloadLocation = downloadLocation
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        //self.isDownloaded = false
        self.url = try container.decode(URL.self, forKey: .url)
        self.index = (decoder.codingPath[0].intValue ?? -1) + 1
    }
}
