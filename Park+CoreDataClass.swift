//
//  Park+CoreDataClass.swift
//  ParkLog
//
//  Created by admin on 10/23/21.
//
//

import Foundation
import CoreData
import UIKit


@objc(Park)
public class Park: NSManagedObject, Decodable {

    public var photoInfoObjects: Dictionary<Int, ImageInfoObject> {
        get {
            let fileManager = FileManager.default
            var dictionary: Dictionary<Int, ImageInfoObject> = [:]
            var object: ImageInfoObject
            if let photo1_url = self.photo1_url,
               let url = URL(string: photo1_url) {
                if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
                   let lastPathComponent = self.photo1_location {
                    let location = documentsPath.appendingPathComponent(lastPathComponent)
                    object = ImageInfoObject(url: url, index: 1, downloadLocation: location)
                    object.isDownloaded = true
                } else {
                    object = ImageInfoObject(url: url, index: 1)
                }
                dictionary[1] = object
            }
            var object2: ImageInfoObject
            if let photo2_url = self.photo2_url,
               let url = URL(string: photo2_url) {
                if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
                   let lastPathComponent = self.photo2_location {
                    let location = documentsPath.appendingPathComponent(lastPathComponent)
                    object2 = ImageInfoObject(url: url, index: 2, downloadLocation: location)
                    object2.isDownloaded = true
                } else {
                    object2 = ImageInfoObject(url: url, index: 2)
                }
                dictionary[2] = object2
            }
            return dictionary
        }
        set {
            self.photo1_url = newValue[1]?.url.absoluteString
            self.photo1_location = newValue[1]?.downloadLocation?.lastPathComponent
            self.photo2_url = newValue[2]?.url.absoluteString
            self.photo2_location = newValue[2]?.downloadLocation?.lastPathComponent
        }
        
    }
    
    private struct AddressInfoObject: Codable {
        let postalCode: String
        let city: String
        let stateCode: String
        let line1: String
        let line2: String
    }
    
    enum CodingKeys: CodingKey {
        case total, data, limit, start
    }
    
    enum DataKeys: CodingKey {
        case name, description, addresses, images
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
              fatalError()
        }
        
        self.init(context: context)
        //self.context = context
        //self.photoInfoObjects = [:]
        
        let outer = try decoder.container(keyedBy: CodingKeys.self)
        
        var inner = try outer.nestedUnkeyedContainer(forKey: .data)
        let data = try inner.nestedContainer(keyedBy: DataKeys.self)
        self.name = try data.decode(String.self, forKey: .name)
        self.guide = try data.decode(String.self, forKey: .description)
        
        //var addresses : Array<AddressInfoObject> = []
        let addresses = try data.decode(Array<AddressInfoObject>.self, forKey: .addresses)
        self.address = "\(addresses[0].line1)\n\(addresses[0].line2)\n\(addresses[0].city), \(addresses[0].stateCode) \(addresses[0].postalCode)"
        
        //var dictionary : [Int: ImageInfoObject] = [:]
        var imageContainer = try data.nestedUnkeyedContainer(forKey: .images)
        //var dictionary : [Int: ImageInfoObject] = [:]
        if let count = imageContainer.count {
            for index in 1...count {
                let imageInfoObject = try imageContainer.decode(ImageInfoObject.self)
                self.photoInfoObjects[index] = imageInfoObject
            }
        }
        //self.photoInfoObjects = dictionary
    }
    /*
    private func downloadImage(url: URL) -> UIImage? {
        var image : UIImage?
        let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            guard let location = location,
                  let imageData = try? Data(contentsOf: location) else {
                return
            }
            image = UIImage(data: imageData)
        }
        task.resume()
        return image
    }
 */
}
