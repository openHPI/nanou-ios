//
//  SpineModelHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 07/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import CoreData
import Foundation

import BrightFutures

class SpineModelHelper {

    class func syncObjects<T: BaseModel>(objectsToUpdateRequest: NSFetchRequest<T>, spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) throws -> [T] {
        let objectsToUpdate = try CoreDataHelper.executeFetchRequest(objectsToUpdateRequest)
        return try self.syncObjects(objectsToUpdate: objectsToUpdate, spineObjects: spineObjects, inject: inject, save: save)
    }

    class func syncObjects<T: BaseModel>(objectsToUpdate: [T], spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool) throws -> [T] {
        var objectsToUpdate = objectsToUpdate

        var cdObjects = [T]()
        if spineObjects.count > 0 {
            // TODO: check if cdType of BaseModelSpine (spineObjects) == T.self
            // possible solution: use typealias on BaseModelSpine
            // but you have to ensure the value of the alias will be of type BaseModel
            let model = T.self
            let entityName = String(describing: model)
            let request = NSFetchRequest<T>(entityName: entityName)
            let entity = NSEntityDescription.entity(forEntityName: entityName, in: CoreDataHelper.context)!

            for spineObject in spineObjects {
                if let id = spineObject.id {
                    let predicate = NSPredicate(format: "id == %@", argumentArray: [id])
                    request.predicate = predicate

                    var cdObject: T

                    let results = try CoreDataHelper.executeFetchRequest(request)
                    if results.isEmpty {
                        cdObject = T.init(entity: entity, insertInto: CoreDataHelper.context)
                        cdObject.setValue(id, forKey: "id")
                    } else {
                        cdObject = results[0]
                    }
                    if spineObject.isLoaded {
                        try cdObject.loadFromSpine(resource: spineObject)
                    }
                    if let dict = inject {
                        cdObject.loadFromDict(dict: dict)
                    }
                    cdObjects.append(cdObject)
                    if let index = objectsToUpdate.index(of: cdObject) {
                        objectsToUpdate.remove(at: index)
                    }
                }
            }
        }
        for object in objectsToUpdate {
            CoreDataHelper.context.delete(object)
        }
        if save {
            CoreDataHelper.saveContext()
        }
        return cdObjects
    }

    class func syncObjectsFuture<T: BaseModel>(objectsToUpdateRequest: NSFetchRequest<T>,
                                 spineObjects: [BaseModelSpine],
                                 inject: [String: AnyObject?]?,
                                 save: Bool) -> Future<[T], NanouError> {
        return Future<[T], NanouError> { complete in
            // XXX: check if this equals ImmediateExecutionContext
            do {
                let cdItems = try syncObjects(objectsToUpdateRequest: objectsToUpdateRequest,
                                              spineObjects: spineObjects,
                                              inject: inject,
                                              save: save)
                return complete(.success(cdItems))
            } catch let error as NanouError {
                return complete(.failure(error))
            } catch {
                return complete(.failure(NanouError.unknownError(error)))
            }
        }
    }

    class func syncObjectsFuture<T: BaseModel>(objectsToUpdate: [T],
                                 spineObjects: [BaseModelSpine],
                                 inject: [String: AnyObject?]?,
                                 save: Bool) -> Future<[T], NanouError> {
        return Future<[T], NanouError> { complete in
            // XXX: check if this equals ImmediateExecutionContext
            do {
                let cdItems = try syncObjects(objectsToUpdate: objectsToUpdate,
                                              spineObjects: spineObjects,
                                              inject: inject,
                                              save: save)
                return complete(.success(cdItems))
            } catch let error as NanouError {
                return complete(.failure(error))
            } catch {
                return complete(.failure(NanouError.unknownError(error)))
            }
        }
    }

}
