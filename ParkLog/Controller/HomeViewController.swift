//
//  HomeViewController.swift
//  ParkLog
//
//  Created by admin on 10/21/21.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    public var context: NSManagedObjectContext?
    public var decoder: JSONDecoder?
    public let parkCodes = ["yell", "yose", "brca", "arch", "jotr"]
    public var parks = Array<Park>()
    public var parkCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Park")
        do {
            self.parkCount = try context?.count(for: fetchRequest)
            if (parkCount == 0 && parkCount != NSNotFound) {
                for parkCode in self.parkCodes {
                    getPark(code: parkCode)
                }
            }
        } catch (let error) {
            print(error.localizedDescription)
        }

        // Do any additional setup after loading the view.
    }
    
    func getPark(code: String) {
        let session = URLSession.shared
        //let limit = 50
        let base = "https://developer.nps.gov/api/v1/parks?"
        let header = ["X-Api-Key": "HXlJloaZkRVXW0DNAn7wuMBDhdlSDgAX5Iyct2AT", "accept": "application/json"]
        let newString = base + "&parkCode=" + code
        guard let url = URL(string: newString) else { fatalError() }
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = header
        request.httpMethod = "GET"
        let dataTask = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else { return }
            guard let data = data else { return }
            do {
                if let park = try self?.decoder?.decode(Park.self, from: data) {
                        self?.parks.append(park)
                }
                try self?.context?.save()
            } catch (let error) {
                print("error decoding data or saving context")
                print(error)
            }
        }
        dataTask.resume()
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "allparks", "myparks":
            let tableViewController = segue.destination as? ParkTableViewController
            tableViewController?.state = ParkTableViewController.State(rawValue: segue.identifier ?? "")
            tableViewController?.context = self.context
            tableViewController?.decoder = self.decoder
        default: return
        }
    }
    

}
