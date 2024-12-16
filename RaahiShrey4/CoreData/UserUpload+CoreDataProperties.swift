//
//  UserUpload+CoreDataProperties.swift
//  RaahiShrey4
//
//  Created by user@59 on 16/12/2024.
//
//

import Foundation
import CoreData


extension UserUpload {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserUpload> {
        return NSFetchRequest<UserUpload>(entityName: "UserUpload")
    }

    @NSManaged public var city: String?
    @NSManaged public var caption: String?
    @NSManaged public var experience: String?

}

extension UserUpload : Identifiable {

}
