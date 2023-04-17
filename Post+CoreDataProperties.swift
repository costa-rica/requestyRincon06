//
//  Post+CoreDataProperties.swift
//  RequestyRincon06
//
//  Created by Nick Rodriguez on 17/04/2023.
//
//

import Foundation
import CoreData


extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post")
    }

    @NSManaged public var date: String?
    @NSManaged public var post_id: Int64
    @NSManaged public var post_text: String?
    @NSManaged public var username: String?

}

extension Post : Identifiable {

}
