//
//  Skill+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 01/05/2025.
//
//

import Foundation
import CoreData


extension Skill {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Skill> {
        return NSFetchRequest<Skill>(entityName: "Skill")
    }

    @NSManaged public var title: String?

}
