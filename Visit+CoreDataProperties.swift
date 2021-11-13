//
//  Visit+CoreDataProperties.swift
//  ParkLog
//
//  Created by admin on 10/23/21.
//
//

import Foundation
import CoreData


extension Visit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Visit> {
        return NSFetchRequest<Visit>(entityName: "Visit")
    }

    @NSManaged public var park: Park?

}

extension Visit : Identifiable {

}
