//
//  CountryListViewController.swift
//  Werkstuk
//
//  Created by student on 13/05/2020.
//  Copyright © 2020 Tim Willaert. All rights reserved.
//

import UIKit
import CoreData

class CountryListViewController: UITableViewController {
    
    //variabele instantiatie
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var opgehaaldeData:[Country] = []
    
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
            NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        
        do{
            opgehaaldeData = try managedContext.fetch(dataFetch) as! [Country]
            return opgehaaldeData.count
        } catch{
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)

        // Configure the cell...
        
        //fetch voorbereiden
        let dataFetch =
            NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        var opgehaaldeData:[Country]
        
        //fetch alle landen en maak cel per land met juiste kleur voor severity
        do{
            opgehaaldeData = try managedContext.fetch(dataFetch) as! [Country]
            let countryName = opgehaaldeData[indexPath.row].name
            let continent = opgehaaldeData[indexPath.row].region
            cell.textLabel!.text = countryName!
            cell.detailTextLabel!.text = continent ?? ""
            
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
        
        //geef landnaam mee aan volgende viewcontroller
        if let nextVC = segue.destination as? CountryDetailViewController
        {
            let indexPath = self.tableView.indexPathForSelectedRow!
            let countryName = self.opgehaaldeData[indexPath.row].name
            nextVC.naam = countryName
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
