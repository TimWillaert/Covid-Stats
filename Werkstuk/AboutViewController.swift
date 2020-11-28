//
//  AboutViewController.swift
//  Werkstuk
//
//  Created by student on 14/05/2020.
//  Copyright © 2020 Tim Willaert. All rights reserved.
//

import UIKit
import CoreData

class AboutViewController: UIViewController {

    //outlet voor firststartup label
    @IBOutlet weak var lblFirstStartup: UILabel!
    
    //variabele instantie
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setStartupLabel()
    }
    
    func setStartupLabel(){
        //fetch voorbereiden
        let firstStartupFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FirstStartup")
        let opgehaaldeStartup:[FirstStartup]
        
        //fetch voor FirstStartup
        do{
            opgehaaldeStartup = try managedContext.fetch(firstStartupFetch) as! [FirstStartup]
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy HH:mm"
            //toon FirstStartup datum op scherm
            lblFirstStartup.text = "First app startup: " + formatter.string(from: opgehaaldeStartup[0].firstStartup!)
        } catch{
            
        }
    }
    
    //open GitHub pagina van Charts wanneer er op de knop wordt gedrukt
    @IBAction func onButtonPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://github.com/danielgindi/Charts")! as URL, options: [:], completionHandler: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
