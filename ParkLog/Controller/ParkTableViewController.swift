//
//  ViewController.swift
//  ParkLog
//
//  Created by admin on 10/20/21.
//

import UIKit
import CoreData

class ParkTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    public var state: State?
    public var context: NSManagedObjectContext?
    public var decoder: JSONDecoder?
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var allParksFetchedResultsController: NSFetchedResultsController<Park> = {
        let fetchRequest = NSFetchRequest<Park>(entityName:"Park")
    
        fetchRequest.fetchLimit = 423
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context!, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
        
    }()
    
    private lazy var myParksFetchedResultsController: NSFetchedResultsController<Park> = {
        let fetchRequest = NSFetchRequest<Park>(entityName: "Park")
        fetchRequest.fetchLimit = 423
        let predicate = NSPredicate(format: "hasBeenVisited == YES")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context!, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        switch self.state {
        case .allParks:
            do {
                try allParksFetchedResultsController.performFetch()
                tableView.reloadData()
            } catch {
                fatalError("Core Data fetch error")
            }
        case .myParks:
            do {
                try myParksFetchedResultsController.performFetch()
                tableView.reloadData()
            } catch {
                fatalError("Core Data fetch error")
            }
        default:
            fatalError()
        }
        
        
    }
    
    private func handleShowDetailSegue(detailViewController: ParkDetailViewController) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        let park: Park?
        detailViewController.context = self.context
        detailViewController.decoder = self.decoder
        
        switch self.state {
        case .allParks:
            park = allParksFetchedResultsController.object(at: indexPath)
        case .myParks:
            park = myParksFetchedResultsController.object(at: indexPath)
        default:
            park = nil
        }
        
        detailViewController.park = park
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showDetail":
            if let viewController = segue.destination as? ParkDetailViewController {
                handleShowDetailSegue(detailViewController: viewController)
            }
        default:
            return
        }
    }
}

// MARK: - Fetched Results Controller Delegate -
extension ParkTableViewController {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let park = anObject as? Park else { return }
        
        switch type {
        case .insert:
          guard let newIndexPath = newIndexPath else { return }
          tableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
          guard let indexPath = indexPath else { return }
          tableView.deleteRows(at: [indexPath], with: .fade)
        case .update:
          guard let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? ParkCell else { return }
            cell.nameLabel.text = park.name
        case .move:
          guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
          tableView.moveRow(at: indexPath, to: newIndexPath)
        default: return
        }
        
    }
}

// MARK: - Table View -
extension ParkTableViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.state {
        case .allParks:
            return allParksFetchedResultsController.sections?.count ?? 0
        case .myParks:
            return myParksFetchedResultsController.sections?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.state {
        case .allParks:
            guard let sectionInfo = allParksFetchedResultsController.sections?[section] else { return 0 }
            return sectionInfo.numberOfObjects
        case .myParks:
            guard let sectionInfo = myParksFetchedResultsController.sections?[section] else { return 0 }
            return sectionInfo.numberOfObjects
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "parkcell", for: indexPath) as! ParkCell
        let park : Park?
        switch self.state {
        case .allParks:
            park = allParksFetchedResultsController.object(at: indexPath)
        case .myParks:
            park = myParksFetchedResultsController.object(at: indexPath)
        default:
            park = nil
        }
        cell.nameLabel.text = park?.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "showDetail", sender: cell)
    }

}

// MARK: - State -
extension ParkTableViewController {
    public enum State: String {
        case allParks = "allparks"
        case myParks = "myparks"
    }
}
