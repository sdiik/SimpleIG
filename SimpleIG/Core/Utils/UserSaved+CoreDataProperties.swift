//
//  UserSaved+CoreDataProperties.swift
//  SimpleIG
//
//  Created by ahmad shiddiq on 21/11/25.
//
//

import Foundation
import CoreData


extension UserSaved {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserSaved> {
        return NSFetchRequest<UserSaved>(entityName: "UserSaved")
    }

    @NSManaged public var username: String?
    @NSManaged public var uid: String?
    @NSManaged public var profileImageUrl: String?
    @NSManaged public var fullname: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var bio: String?

}

extension UserSaved : Identifiable {

}
