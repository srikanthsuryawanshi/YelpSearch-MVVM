//
//  CoreController.swift
//  YelpSearch
//
//  Created by Srikanth SP on 30/03/22.
//

import Foundation
import CoreData


class CoreController {
    
    static var shared: CoreController = {
        return CoreController()
    }()
    
    private init(){
        let _ = persistentContainer
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "YelpCache")
            container.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Unable to load persistent stores: \(error)")
                }
            }
            return container
        }()
    
    private func saveContext () {
            let context = persistentContainer.viewContext
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    
}

extension CoreController: PersistenceProtocol {
    func save(restaurant: RestaurantDetail) {
        let context = persistentContainer.viewContext
        
        let restaurantMO = NSEntityDescription.insertNewObject(forEntityName: "RestaurantEntity",
                                                             into: context) as! RestaurantEntity
        
        restaurantMO.name = restaurant.name
        restaurantMO.imageUrl = restaurant.imageUrl
        restaurantMO.phone = restaurant.phone
        restaurantMO.price = restaurant.price
        restaurantMO.ratings = restaurant.ratings
        restaurantMO.location = restaurant.address
        restaurantMO.id = restaurant.id
        restaurantMO.timestamp = NSDate().timeIntervalSince1970
        saveContext()
    }
    
    func recentVisits() -> [RestaurantDetail] {
        let context = persistentContainer.viewContext

        var fetched = [RestaurantDetail]()
        
        let request:NSFetchRequest<RestaurantEntity> = RestaurantEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        do{
            let restaurants = try context.fetch(request)
            for r in restaurants {
                if let id = r.id {
                    var restaurantDetail = RestaurantDetail( id: id)
                    restaurantDetail.name = r.name
                    restaurantDetail.imageUrl = r.imageUrl
                    restaurantDetail.phone = r.phone
                    restaurantDetail.price = r.price
                    restaurantDetail.ratings = r.ratings
                    restaurantDetail.address = r.location
                    fetched.append(restaurantDetail)
                }
            }
        }catch
        {
            print("Could not load save data: \(error.localizedDescription)")
        }
        
        return fetched
    }
    
    
}
