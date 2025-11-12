//
//  ItemStore.swift
//  LootLogger
//
//  Created by Eltonia Leonard on 10/31/25.
//

import UIKit

// Define an error type that the ItemStore can throw
enum ItemStoreError: Error {
    case failedToSave
}

class ItemStore {

    var allItems = [Item]()
    let itemArchiveURL: URL = {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("items.plist")
    }()

    //Adding an item creation method
    @discardableResult func createItem() -> Item {
        let newItem = Item(random: true)

        allItems.append(newItem)

        return newItem
    }
    
    func removeItem(_ item: Item) {
        if let index = allItems.firstIndex(of: item) {
            allItems.remove(at: index)
        }
    }
    
    func moveItem(from fromIndex: Int, to toIndex: Int) {
        if fromIndex == toIndex {
            return
        }

        // Get reference to object being moved so you can reinsert it
        let movedItem = allItems[fromIndex]

        // Remove item from array
        allItems.remove(at: fromIndex)

        // Insert item in array at new location
        allItems.insert(movedItem, at: toIndex)
    }
    func saveChanges() throws -> Bool {
        
        print("Saving items to: \(itemArchiveURL)")

        do {
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(allItems)
                try data.write(to: itemArchiveURL, options: [.atomic])
                    print("Saved all of the items")
                    return true
            } catch let encodingError {
                print("Error encoding allItems: \(encodingError)")
                throw ItemStoreError.failedToSave
            }
       
    }
    @objc func saveChangesSilently() {
        do {
            _ = try saveChanges()
        } catch {
            print("Error saving changes silently: \(error)")
        }
    }

    
    init() {
        do {
                let data = try Data(contentsOf: itemArchiveURL)
                let unarchiver = PropertyListDecoder()
                let items = try unarchiver.decode([Item].self, from: data)
                allItems = items
            } catch {
                print("Error reading in saved items: \(error)")
            }

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(saveChangesSilently),
                                       name: UIScene.didEnterBackgroundNotification,
                                       object: nil)
    }
    
//    init() {
//        for _ in 0..<5 {
//            createItem()
//        }
//    }
}
