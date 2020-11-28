//
//  ViewController.swift
//  Werkstuk
//
//  Created by student on 02/05/2020.
//  Copyright © 2020 Tim Willaert. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    //outlets
    @IBOutlet weak var lblTotalCases: UITextField!
    @IBOutlet weak var lblTotalDeaths: UITextField!
    @IBOutlet weak var lblYourCountry: UILabel!
    @IBOutlet weak var lblTotalCasesCountry: UILabel!
    @IBOutlet weak var lblYourCountryDeaths: UILabel!
    @IBOutlet weak var lblTotalDeathsCountry: UILabel!
    @IBOutlet weak var lblLastRefreshed: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingScreen: UIView!
    
    //refresh data functie
    @IBAction func refreshData(_ sender: Any) {
        self.clearData()
        self.checkData()
    }
    
    //variabele instantiatie
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //Gebruikte bron om land op te halen: https://stackoverflow.com/questions/35682554/getting-country-name-from-country-code
        let countryCode = Locale.current.regionCode
        let countryName = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode!)
        
        //zet huidig land in labels
        lblYourCountry.text = self.flag(country: countryCode!) + " " + (countryName?.uppercased())! + " TOTAL CASES"
        lblYourCountryDeaths.text = self.flag(country: countryCode!) + " " + (countryName?.uppercased())! + " TOTAL DEATHS"
        
        //check of er data aanwezig is in CoreData
        self.checkData()
    }
    
    //run deze functie om het laadscherm te tonen
    func startLoading(){
        activityIndicator.startAnimating()
        loadingScreen.isHidden = false
    }
    
    //run deze functie om het laadscherm te stoppen
    func stopLoading(){
        activityIndicator.stopAnimating()
        loadingScreen.isHidden = true
    }
    
    //Functie om de vlag emoji op te halen
    //Gebruikte bron: https://stackoverflow.com/questions/30402435/swift-turn-a-country-code-into-a-emoji-flag-via-unicode
    func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
    
    //Toon data uit CoreData als het beschikbaar is, anders data ophalen
    func checkData(){
        
        //fetch voorbereiden
        let dataFetch =
            NSFetchRequest<NSFetchRequestResult>(entityName: "LastRefreshed")
        let opgehaaldeData:[LastRefreshed]
        
        //fetch last refreshed datum
        do{
            opgehaaldeData = try managedContext.fetch(dataFetch) as! [LastRefreshed]
            //als er data is tonen, anders laadscherm tonen en data ophalen
            if(opgehaaldeData.count != 0){
                self.showData()
                self.stopLoading()
            } else{
                self.startLoading()
                self.getData()
            }
        } catch{
            fatalError("Failed to fetch data: \(error)")
        }
        
        //fetch voorbereiden
        let firstStartupFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FirstStartup")
        let opgehaaldeStartup:[FirstStartup]
        
        //fetch eerste startup datum
        do{
            opgehaaldeStartup = try managedContext.fetch(firstStartupFetch) as! [FirstStartup]
            //slaag datum op als er nog geen datum aanwezig is
            if(opgehaaldeStartup.count == 0){
                let firststartup = FirstStartup(context: managedContext)
                firststartup.firstStartup = Date()
                try self.managedContext.save()
            }
        } catch{
            
        }
    }
    
    //Toon data
    func showData(){
        
        //fetch voorbereiden
        let dataFetch =
            NSFetchRequest<NSFetchRequestResult>(entityName: "CoronaData")
        var opgehaaldeData:[CoronaData]
        
        //variabelen
        var totalCases = 0
        var totalDeaths = 0
        var totalCasesCountry = 0
        var totalDeathsCountry = 0
        
        //Gebruikte bron voor numberformatter: https://stackoverflow.com/questions/51623312/how-to-add-commas-or-space-for-every-4-digits-in-swift-4
        
        //numberformatter om spaties toe te voegen in nummers
        let separator = " "
        let formatter = NumberFormatter()
        formatter.positiveFormat = "#,###,###"
        formatter.groupingSeparator = separator
        
        //fetch voor CoronaData
        do {
            opgehaaldeData = try managedContext.fetch(dataFetch) as! [CoronaData]
            //loop over alle records en tel cases en deaths op
            for data in opgehaaldeData{
                totalCases += Int(data.cases!)!
                totalDeaths += Int(data.deaths!)!
            }
            //toon totaal aantal cases en deaths
            self.lblTotalCases.text = formatter.string(from: NSNumber(value: totalCases))
            self.lblTotalDeaths.text = formatter.string(from: NSNumber(value: totalDeaths))
            
            //haal data op van huidige land v/d gebruiker
            dataFetch.predicate = NSPredicate(format: "geoId == %@", Locale.current.regionCode!)
            opgehaaldeData = try managedContext.fetch(dataFetch) as! [CoronaData]
            
            //tel totaal aantal cases en deaths op voor huidig land
            for data in opgehaaldeData{
                totalCasesCountry += Int(data.cases!)!
                totalDeathsCountry += Int(data.deaths!)!
            }
            
            //toon totaal aantal cases en deaths voor huidig land
            self.lblTotalCasesCountry.text = formatter.string(from: NSNumber(value: totalCasesCountry))
            self.lblTotalDeathsCountry.text = formatter.string(from: NSNumber(value: totalDeathsCountry))
            
        } catch {
            fatalError("Failed to fetch data: \(error)")
        }
        
        //fetch voorbereiden
        let lastRefreshedFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LastRefreshed")
        var lastRefreshed:[LastRefreshed]
        
        //fetch voor last refreshed datum
        do{
            lastRefreshed = try managedContext.fetch(lastRefreshedFetch) as! [LastRefreshed]
            //toon last refreshed datum op scherm
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy HH:mm"
            self.lblLastRefreshed.text = "Last refreshed: " + formatter.string(from: lastRefreshed[0].lastRefreshed!)
            
        } catch{
            fatalError("Failed to fetch last refresh: \(error)")
        }
         
    }
    
    //Clear CoreData bij refresh
    func clearData(){
        
        //Batch delete gehaald van: https://cocoacasts.com/how-to-delete-every-record-of-a-core-data-entity
        
        //delete request voorbereiden
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoronaData")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        //delete request voor CoronaData
        do {
            try managedContext.execute(batchDeleteRequest)
            print("Cleared CoronaData")
        } catch {
            // Error Handling
        }
        
        //delete request voorbereiden
        let refreshedFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LastRefreshed")
        let refreshedDeleteRequest = NSBatchDeleteRequest(fetchRequest: refreshedFetchRequest)
        
        //delete request voor LastRefreshed
        do {
            try managedContext.execute(refreshedDeleteRequest)
            print("Cleared LastRefreshed")
        } catch {
            // Error Handling
        }
        
        //delete request voorbereiden
        let countriesFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        let countriesDeleteRequest = NSBatchDeleteRequest(fetchRequest: countriesFetchRequest)
        
        //delete request voor Country
        do {
            try managedContext.execute(countriesDeleteRequest)
            print("Cleared Countries")
        } catch {
            // Error Handling
        }
        
        //delete request voorbereiden
        let continentsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Continent")
        let continentsDeleteRequest = NSBatchDeleteRequest(fetchRequest: continentsFetchRequest)
        
        //delete request voor Continent
        do {
            try managedContext.execute(continentsDeleteRequest)
            print("Cleared Continents")
        } catch {
            // Error Handling
        }
    }
    
    //Haal data op van API
    func getData(){
        
        // URL
            let url = URL(string: "https://opendata.ecdc.europa.eu/covid19/casedistribution/json/")
            // URLRequest
            let urlRequest = URLRequest(url: url!)
            
            // set up the session
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            // the method dataTask creates a task that retrieves the contents of the specified URL then calls a handler upon completion.
            let task = session.dataTask(with: urlRequest) {
                (data, response, error) in
                
                // check for any errors
                guard error == nil else {
                    print("error calling GET")
                    print(error!)
                    return
                }
                
                // make sure we got data
                guard let responseData = data else {
                    print("Error: did not receive data")
                    return
                }
                
                // parse the result
                do {
                    // the parsedData object is a dictionary so we cast to [String: AnyObject]
                    guard let parsedData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                        print("error trying to convert data to JSON")
                        return
                    }
                    
                   // get all records and cast as array
                    guard let contentForRecords = parsedData["records"] as? [AnyObject] else {
                        print("Could not get records from JSON")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        // save data to CoreData
                        
                        //maak nieuwe LastRefreshed aan
                        let refresh = LastRefreshed(context: self.managedContext)
                        refresh.lastRefreshed = Date()
                        
                        //arrays om landen en continenten op te slagen
                        var countries = Array<String>()
                        var continents = Array<String>()
                        
                        //loop over alle records en slaag op als CoronaData
                        for data in contentForRecords{
                        
                            let record = CoronaData(context: self.managedContext)
                            let cases = data["cases"] as! Int
                            record.cases = String(cases)
                            record.continentExp = data["continentExp"] as? String
                            let rawName = data["countriesAndTerritories"] as? String
                            record.countriesAndTerritories = rawName!.replacingOccurrences(of: "_", with: " ")
                            record.countryterritoryCode = data["countryterritoryCode"] as? String
                            record.dateRep = data["dateRep"] as? String
                            record.day = data["day"] as? String
                            let deaths = data["deaths"] as! Int
                            record.deaths = String(deaths)
                            record.geoId = data["geoId"] as? String
                            record.month = data["month"] as? String
                            record.popData2018 = data["popData2019"] as? String
                            record.year = data["year"] as? String
                            
                            //voeg land toe als het nog niet bestaat
                            if(!countries.contains(record.countriesAndTerritories!)){
                                countries.append(record.countriesAndTerritories!)
                                let country = Country(context: self.managedContext)
                                country.code = record.countryterritoryCode ?? ""
                                country.name = record.countriesAndTerritories!.replacingOccurrences(of: "_", with: " ")
                                country.region = record.continentExp ?? ""
                            }
                            
                            //voeg continent toe als het nog niet bestaat
                            if(!continents.contains(record.continentExp!)){
                                continents.append(record.continentExp!)
                                let continent = Continent(context: self.managedContext)
                                continent.name = record.continentExp!
                            }
                            
                            do {
                                try self.managedContext.save()
                            } catch {
                                fatalError("Failure to save context: \(error)")
                            }
                            
                        }
                        
                        //fetch voorbereiden
                        let countryFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
                        var countryData:[Country]
                        var coronaData:[CoronaData]
                        
                        //fetch voor alle landen
                        do{
                            try countryData = self.managedContext.fetch(countryFetch) as! [Country]
                            
                            //loop over alle landen, haal alle records op per land, tel alle cases op en bereken severity
                            for country in countryData{
                                
                                let coronaDataFetch =
                                    NSFetchRequest<NSFetchRequestResult>(entityName: "CoronaData")
                                coronaDataFetch.predicate = NSPredicate(format: "countriesAndTerritories == %@", country.name!)
                                
                                var countryTotalCases = 0
                                
                                do {
                                    try coronaData = self.managedContext.fetch(coronaDataFetch) as! [CoronaData]
                                    for data in coronaData{
                                        countryTotalCases += Int(data.cases!)!
                                    }
                                
                                    if(countryTotalCases > 40000){
                                        country.severity = "High"
                                    } else if(countryTotalCases > 4000){
                                        country.severity = "Medium"
                                    } else{
                                        country.severity = "Low"
                                    }
                                } catch {
                                    
                                }
                                
                                do {
                                    try self.managedContext.save()
                                } catch {
                                    fatalError("Failure to save context: \(error)")
                                }
                                
                            }
                        } catch{
                            
                        }
                        
                        //fetch voorbereiden
                        let continentFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Continent")
                        var continentData:[Continent]
                        var newCoronaData:[CoronaData]
                        
                        //fetch voor alle continenten
                        do{
                            try continentData = self.managedContext.fetch(continentFetch) as! [Continent]
                            
                            //loop over alle continenten, haal alle records op, tel alle cases op en bereken severity
                            for continent in continentData{
                                let coronaDataFetch =
                                    NSFetchRequest<NSFetchRequestResult>(entityName: "CoronaData")
                                coronaDataFetch.predicate = NSPredicate(format: "continentExp == %@", continent.name!)
                                
                                var continentTotalCases = 0
                                
                                do{
                                    try newCoronaData = self.managedContext.fetch(coronaDataFetch) as! [CoronaData]
                                    for data in newCoronaData{
                                        continentTotalCases += Int(data.cases!)!
                                    }
                                    
                                    if(continentTotalCases > 100000){
                                        continent.severity = "High"
                                    } else if(continentTotalCases > 5000){
                                        continent.severity = "Medium"
                                    } else{
                                        continent.severity = "Low"
                                    }
                                    
                                } catch{
                                    
                                }
                                
                                do {
                                    try self.managedContext.save()
                                } catch {
                                    fatalError("Failure to save context: \(error)")
                                }
            
                            }
                        } catch{
                            
                        }
                        
                        print("Data saved")
                        self.showData()
                        self.stopLoading()
                        
                    }
                    
                } catch  {
                    print("error trying to convert data to JSON")
                    return
                }
                
            }
            
            // Newly-initialized tasks begin in a suspended state, so you need to call this method to start the task.
            task.resume()
        
    }
}

