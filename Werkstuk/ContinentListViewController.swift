//
//  ContinentListViewController.swift
//  Werkstuk
//
//  Created by student on 15/05/2020.
//  Copyright © 2020 Tim Willaert. All rights reserved.
//

import UIKit
import CoreData

class ContinentListViewController: UITableViewController {
    
    //variabele instantiatie
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var opgehaaldeData:[Continent] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let dataFetch =
            NSFetchRequest<NSFetchRequestResult>(entityName: "Continent")
        
        do{
            opgehaaldeData = try managedContext.fetch(dataFetch) as! [Continent]
            return opgehaaldeData.count
        } catch{
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "continentCell", for: indexPath)

        // Configure the cell...
        
        //haal alle continenten op en maak per continent een cel met de juiste kleur van severity
        let dataFetch =
            NSFetchRequest<NSFetchRequestResult>(entityName: "Continent")
        var opgehaaldeData:[Continent]
        
        do{
            opgehaaldeData = try managedContext.fetch(dataFetch) as! [Continent]
            let continentName = opgehaaldeData[indexPath.row].name
            cell.textLabel!.text = continentName!
            
            //severity kleur
            if(opgehaaldeData[indexPath.row].severity == "High"){
                cell.tintColor = UIColor.systemRed
            } else if(opgehaaldeData[indexPath.row].severity == "Medium"){
                cell.tintColor = UIColor.systemOrange
            } else{
                cell.tintColor = UIColor.systemGreen
            }
    
        } catch{
            
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //stuur naam van continent mee naar volgende viewcontroller
        if let nextVC = segue.destination as? ContinentDetailViewController
        {
            let indexPath = self.tableView.indexPathForSelectedRow!
            let continentName = self.opgehaaldeData[indexPath.row].name
            nextVC.naam = continentName
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
