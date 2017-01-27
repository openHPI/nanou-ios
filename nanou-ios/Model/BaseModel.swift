//
//  BaseModel.swift
//  nanou-ios
//
//  Created by Max Bothe on 07/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import CoreData
import Spine

class BaseModel: NSManagedObject {

    required override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    func loadFromSpine<T: BaseModel>(resource: BaseModelSpine<T>) throws {
        for field in type(of: resource).fields {
            var value = resource.value(forKey: field.name)
            if value is NSNull {
                // This can happen, e.g. if a DateAttribute cannot be converted to NSDate.
                value = nil
            }
            if field is CompoundAttribute {
                if let value = value as? CompoundValue {
                    value.saveToCoreData(self)
                }
            } else if field is ToOneRelationship {
                if let value = value as? BaseModelSpine<T> {
                    let currentRelatedObject = self.value(forKey: field.name) as? T
                    let relatedObjects = currentRelatedObject != nil ? [currentRelatedObject!] : []
                    let cdObjects = try SpineModelHelper.syncObjects(objectsToUpdate: relatedObjects, spineObjects: [value], inject: nil, save: false)
                    self.setValue(cdObjects[0], forKey: field.name)
                }
            } else if field is ToManyRelationship {
                if let value = value as? ResourceCollection {
                    let spineObjects = value.resources as! [BaseModelSpine<T>]  // tailor:disable
                    let relatedObjects = self.value(forKey: field.name) as? [T] ?? []
                    let cdObjects = try SpineModelHelper.syncObjects(objectsToUpdate: relatedObjects, spineObjects: spineObjects, inject: nil, save: false)
                    self.setValue(NSSet(array: cdObjects), forKey: field.name)
                }
            } else if field is URLAttribute {
                if let url = value as? URL {
                    self.setValue(url.absoluteString, forKey: field.name)
                }
            } else {
                self.setValue(value, forKey: field.name)
            }
        }
    }

    func loadFromDict(dict: [String: AnyObject?]) {
        for (key, value) in dict {
            self.setValue(value, forKey: key)
        }
    }

    func resource<T: BaseModel>() -> BaseModelSpine<T> {
        fatalError()
    }

}
