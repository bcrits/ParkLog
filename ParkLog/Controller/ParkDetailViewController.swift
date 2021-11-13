//
//  ParkDetailViewController.swift
//  ParkLog
//
//  Created by admin on 10/21/21.
//

import UIKit
import CoreData

class ParkDetailViewController: UIViewController {
    
    // MARK: - Properties and Outlets -
    
    var context: NSManagedObjectContext?
    var decoder: JSONDecoder?
    var park: Park?
    var photoDownloads: Dictionary<URL, PhotoDownload> = [:]
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    @IBOutlet weak var photo1View: UIImageView!
    @IBOutlet weak var photo2View: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var guideLabel: UILabel!
    
    lazy var urlSession: URLSession = {
      let configuration = URLSessionConfiguration.default
      return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    // MARK: - View Controller -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = park?.name
        guideLabel.text = park?.guide
        if let photoInfoObjects = park?.photoInfoObjects {
            for (_, photo) in photoInfoObjects {
                self.photoDownloads[photo.url] = PhotoDownload(photo)
            }
        }
        
        for (url, download) in self.photoDownloads {
            if let imageInfoObject = download.imageInfoObject {
            if imageInfoObject.isDownloaded {
                switch imageInfoObject.index {
                case 1:
                    displayPhoto(imageInfoObject, imageView: self.photo1View)
                case 2:
                    displayPhoto(imageInfoObject, imageView: self.photo2View)
                default:
                    break
                }
            } else {
                let task = urlSession.downloadTask(with: url)
                task.resume()
            }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    func displayPhoto(_ object: ImageInfoObject, imageView: UIImageView) {
        guard let location = object.downloadLocation else { return }
        do {
        let imageData = try Data(contentsOf: location)
        let image = UIImage(data: imageData)
        DispatchQueue.main.async {
            imageView.image = image
        }
        } catch (let error) {
            print(error)
        }
        
    }
    
    func localFilePath(for url: URL) -> URL {
      return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
}
    
    //MARK: - URLSessionDownloadDelegate -
    
    extension ParkDetailViewController: URLSessionDownloadDelegate {
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let error = error {
                print(error.localizedDescription)
            }
            //print("finished")
        }
        
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            let fileManager = FileManager.default
            guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
                  let sourceURL = downloadTask.originalRequest?.url,
                  let download = self.photoDownloads[sourceURL] else {
                    fatalError()
            }
            
            let lastPathComponent = sourceURL.lastPathComponent
            let destinationURL = documentsPath.appendingPathComponent(lastPathComponent)
            
            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.copyItem(at: location, to: destinationURL)
                let index = download.imageInfoObject.index
                let newImageInfoObject = ImageInfoObject(url: sourceURL, index: index, downloadLocation: destinationURL)
                self.park?.photoInfoObjects[index] = newImageInfoObject
                switch newImageInfoObject.index {
                case 1:
                    displayPhoto(newImageInfoObject, imageView: self.photo1View)
                case 2:
                    displayPhoto(newImageInfoObject, imageView: self.photo2View)
                default:
                    break
                }
                try context?.save()
            } catch {
                print(error)
            }
            
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


