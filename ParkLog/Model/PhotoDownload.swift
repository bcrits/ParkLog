//
//  ImageDownload.swift
//  ParkLog
//
//  Created by admin on 11/5/21.
//

import Foundation

class PhotoDownload : NSObject, URLSessionDownloadDelegate {
    var imageInfoObject: ImageInfoObject!
    var downloadTask: URLSessionDownloadTask?
    
    public convenience init(_ object: ImageInfoObject) {
        self.init()
        self.imageInfoObject = object
        //self.imageInfoObject.index = index
    }
    
}

// MARK: - URLSessionDownload Delegate -
extension PhotoDownload {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        //print("finished")
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
      
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
              let url = imageInfoObject?.url else {
                fatalError()
        }
        let lastPathComponent = url.lastPathComponent
        let destinationUrl = documentsPath.appendingPathComponent(lastPathComponent)
        do {
            if fileManager.fileExists(atPath: destinationUrl.path) {
                try fileManager.removeItem(at: destinationUrl)
            }
            try fileManager.copyItem(at: location, to: destinationUrl)
            self.imageInfoObject?.downloadLocation = destinationUrl
        } catch {
            print(error)
        }
      
    }
    
}
