//
//  ItemsViewController.swift
//  LootLogger
//
//  Created by Eltonia Leonard on 10/31/25.
//

import UIKit

class ItemsViewController: UITableViewController {
    
    var itemStore: ItemStore!
    var imageStore: ImageStore!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem){
        // Create a new item and add it to the store
          let newItem = itemStore.createItem()

          // Figure out where that item is in the array
          if let index = itemStore.allItems.firstIndex(of: newItem) {
              let indexPath = IndexPath(row: index, section: 0)

              // Insert this new row into the table
              tableView.insertRows(at: [indexPath], with: .automatic)
          }
    }
    
    //Set number of rows in cell
    override func tableView(_ tableView: UITableView,
            numberOfRowsInSection section: Int) -> Int {
        return itemStore.allItems.count
    }
    
    override func tableView(_ tableView: UITableView,
            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get a new or recycled cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell",
                                                     for: indexPath) as! ItemCell

        // Set the text on the cell with the description of the item
        // that is at the nth index of items, where n = row this cell
        // will appear in on the table view
        let item = itemStore.allItems[indexPath.row]

        // Configure the cell with the Item
        cell.nameLabel.text = item.name
        cell.serialNumberLabel.text = item.serialNumber
        cell.valueLabel.text = "$\(item.valueInDollars)"
        
        // **BRONZE CHALLENGE: CELL COLORS**
        if item.valueInDollars < 50 {
            // Green if value is less than 50
            cell.valueLabel.textColor = UIColor.systemGreen
        } else {
            // Red if value is greater than or equal to 50
            cell.valueLabel.textColor = UIColor.systemRed
            }

        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        // If the table view is asking to commit a delete command...
        if editingStyle == .delete {
            let item = itemStore.allItems[indexPath.row]

            // Remove the item from the store
            itemStore.removeItem(item)
            
            // Remove the item's image from the image store
            imageStore.deleteImage(forKey: item.itemKey)

            // Also remove that row from the table view with an animation
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        // Update the model
        itemStore.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the triggered segue is the "showItem" segue
        switch segue.identifier {
        case "showItem":
            // Figure out which row was just tapped
            if let row = tableView.indexPathForSelectedRow?.row {

                // Get the item associated with this row and pass it along
                let item = itemStore.allItems[row]
                let detailViewController
                        = segue.destination as! DetailViewController
                detailViewController.item = item
                detailViewController.imageStore = imageStore
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65
    }
}

