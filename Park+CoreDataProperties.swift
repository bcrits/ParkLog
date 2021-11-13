//
//  Park+CoreDataProperties.swift
//  ParkLog
//
//  Created by admin on 11/4/21.
//
//

import Foundation
import CoreData


extension Park {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Park> {
        return NSFetchRequest<Park>(entityName: "Park")
    }

    @NSManaged public var address: String?
    @NSManaged public var guide: String?
    @NSManaged public var name: String?
    @NSManaged public var photo1_location: String?
    @NSManaged public var photo1_url: String?
    @NSManaged public var photo2_location: String?
    @NSManaged public var photo2_url: String?
    @NSManaged public var hasBeenVisited: Bool
    @NSManaged public var visits: NSSet?

}

// MARK: Generated accessors for visits
extension Park {

    @objc(addVisitsObject:)
    @NSManaged public func addToVisits(_ value: Visit)

    @objc(removeVisitsObject:)
    @NSManaged public func removeFromVisits(_ value: Visit)

    @objc(addVisits:)
    @NSManaged public func addToVisits(_ values: NSSet)

    @objc(removeVisits:)
    @NSManaged public func removeFromVisits(_ values: NSSet)

}

extension Park : Identifiable {

}
