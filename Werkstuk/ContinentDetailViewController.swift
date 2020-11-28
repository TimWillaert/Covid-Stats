//
//  ContinentDetailViewController.swift
//  Werkstuk
//
//  Created by student on 15/05/2020.
//  Copyright © 2020 Tim Willaert. All rights reserved.
//

import UIKit
import CoreData

class ContinentDetailViewController: UIViewController {
    
    //voor het implementeren van de page views heb ik gebruik gemaakt van de tutorial die op Canvas gelinkt stond
    
    //variabele instantiatie
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var naam: String!
    var totalCases = 0
    var totalDeaths = 0
    var worstCountries: [Int: String] = [:]
    @IBOutlet weak var lblTotalCases: UILabel!
    @IBOutlet weak var lblSeverity: UILabel!
    @IBOutlet weak var lblTotalDeaths: UILabel!
    @IBOutlet weak var lblRatio: UILabel!
    
    @IBOutlet weak var miniCountryView: UIView!
    var dataSource: Array<String> = []
    var currentViewControllerIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.naam
        self.showData()
        self.configurePageView()
    }
    
    //code van tutorial
    func configurePageView(){
        guard let pageViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: PageViewController.self)) as? PageViewController else{
            return
        }
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        miniCountryView.addSubview(pageViewController.view)
        pageViewController.view.layer.cornerRadius = 10
        
        let views: [String: Any] = ["pageView": pageViewController.view]
        
        miniCountryView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[pageView]-0-|",
                                                                      options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                      metrics: nil,
                                                                      views: views))
        
        miniCountryView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[pageView]-0-|",
                                                                    options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                    metrics: nil,
                                                                    views: views))
        
        guard let startingViewController = detailViewControllerAt(index: currentViewControllerIndex) else{
            return
        }
        
        pageViewController.setViewControllers([startingViewController], direction: .forward, animated: true)
        
    }
    
    //code van tutorial
    func detailViewControllerAt(index: Int) -> CountryMiniViewController? {
        
        if(index >= dataSource.count || dataSource.count == 0){
            return nil
        }
        
        guard let countryMiniViewController = storyboard?.instantiateViewController(identifier: String(describing: CountryMiniViewController.self)) as? CountryMiniViewController else{
            return nil
        }
        
        countryMiniViewController.index = index
        countryMiniViewController.countryName = dataSource[index]
        
        return countryMiniViewController
    }
    
    //toon data op scherm
    func showData(){
        //Gebruikte bron voor numberformatter: https://stackoverflow.com/questions/51623312/how-to-add-commas-or-space-for-every-4-digits-in-swift-4
        
        let separator = " "
        let formatter = NumberFormatter()
        formatter.positiveFormat = "#,###,###"
        formatter.groupingSeparator = separator
        
        //fetch voorbereiden
        let dataFetch =
            NSFetchRequest<NSFetchRequestResult>(entityName: "CoronaData")
        dataFetch.predicate = NSPredicate(format: "continentExp == %@", self.naam)
        var opgehaaldeData:[CoronaData]
        
        let continentFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Continent")
        continentFetch.predicate = NSPredicate(format: "name == %@", self.naam)
        var continentData:[Continent]
        
        let countriesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        countriesFetch.predicate = NSPredicate(format: "region == %@", self.naam)
        var countriesData:[Country]
        
        //fetch Continent en Country/CoronaData van huidig continent
        do {
            try opgehaaldeData = try managedContext.fetch(dataFetch) as! [CoronaData]
            try continentData = try managedContext.fetch(continentFetch) as! [Continent]
            try countriesData = try managedContext.fetch(countriesFetch) as! [Country]
            
            //loop over CoronaData en tel totaal aantal cases en deaths op
            for data in opgehaaldeData{
                totalCases += Int(data.cases!)!
                totalDeaths += Int(data.deaths!)!
            }
            
            //loop over Country en haal alle records op voor dat land, zodat we dit later kunnen toevoegen aan de pageview
            for country in countriesData{
                var countryTotalCases = 0
                let countryFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CoronaData")
                countryFetch.predicate = NSPredicate(format: "countriesAndTerritories == %@", country.name!)
                var countryData:[CoronaData]
                do{
                    try countryData = try managedContext.fetch(countryFetch) as! [CoronaData]
                    //tel totaal aantal cases op en voeg toe aan worstCountries dictionary
                    for countryData in countryData{
                        countryTotalCases += Int(countryData.cases!)!
                    }
                    worstCountries[countryTotalCases] = country.name!
                } catch{
                    
                }
            }
            
            //sorteer worstCountries dictionary en voeg de ergste 10 landen toe aan de dataSource voor pageview
            let sortedValues = Array(worstCountries.keys).sorted(by: >)
            for (index, element) in sortedValues.enumerated(){
                if(index < 10){
                    dataSource.append(worstCountries[element]!)
                }
            }
            
            //toon totaal aantal cases en deaths, death/case ratio en severity
            self.lblTotalCases.text = formatter.string(from: NSNumber(value: totalCases))
            self.lblTotalDeaths.text = formatter.string(from: NSNumber(value: totalDeaths))
            
            let ratio = (Float(totalDeaths) / Float(totalCases)) * 100
            self.lblRatio.text = String(ratio).prefix(4) + "%"
            
            self.lblSeverity.text = continentData[0].severity!
            if(continentData[0].severity == "High"){
                self.lblSeverity.textColor = UIColor.systemRed
            } else if(continentData[0].severity == "Medium"){
                self.lblSeverity.textColor = UIColor.systemOrange
            } else{
                self.lblSeverity.textColor = UIColor.systemGreen
            }
            
        } catch {
            
        }
        
    }

}

//code van tutorial
extension ContinentDetailViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource{
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int{
        return currentViewControllerIndex
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return dataSource.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let countryMiniViewController = viewController as? CountryMiniViewController
        guard var currentIndex = countryMiniViewController?.index else{
            return nil
        }
        
        currentViewControllerIndex = currentIndex
        
        if(currentIndex == 0){
            return nil
        }
        
        currentIndex -= 1
        
        return detailViewControllerAt(index: currentIndex)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let countryMiniViewController = viewController as? CountryMiniViewController
        guard var currentIndex = countryMiniViewController?.index else{
            return nil
        }
        
        if(currentIndex == dataSource.count){
            return nil
        }
        
        currentIndex += 1
        
        currentViewControllerIndex = currentIndex
        
        return detailViewControllerAt(index: currentIndex)
    }
    
}
