//
//  DatabaseHelper.swift
//  RaahiShrey4
//
//  Created by user@59 on 16/12/2024.
//

import Foundation
import CoreData
import UIKit

class DatabaseHelper {
    
    static let sharedInstance = DatabaseHelper()
    
    var context : NSManagedObjectContext{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Couldn't find AppDelegate")
        }
        
        return appDelegate.persistentContainer.viewContext
    }
    
    func save(object: [String: String]) {
        // Safely unwrap the entity
        guard let entity = NSEntityDescription.entity(forEntityName: "UserUpload", in: context) else {
            print("Failed to find entity ")
            return
        }
        
        let userupload = NSManagedObject(entity: entity, insertInto: context) as! UserUpload
        
        userupload.city = object["city"]
        userupload.caption = object["caption"]
        userupload.experience = object["experience"]
        
        do {
            try context.save()
            print("Data saved successfully")
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
        }
    }
}
