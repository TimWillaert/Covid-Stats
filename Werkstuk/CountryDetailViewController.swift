//
//  CountryDetailViewController.swift
//  Werkstuk
//
//  Created by student on 13/05/2020.
//  Copyright © 2020 Tim Willaert. All rights reserved.
//

import UIKit
import CoreData
import Charts
import TinyConstraints

class CountryDetailViewController: UIViewController {
    
    //charts voorbereiden
    lazy var casesChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.legend.enabled = false
        chartView.xAxis.labelFont = .systemFont(ofSize: 12)
        chartView.xAxis.labelTextColor = .systemGray
        chartView.leftAxis.labelFont = .systemFont(ofSize: 12)
        chartView.leftAxis.labelTextColor = .systemGray
        chartView.leftAxis.setLabelCount(4, force: true)
        chartView.drawBordersEnabled = false
        chartView.animate(xAxisDuration: 1.5)
        return chartView
    }()
    
    lazy var deathsChartView: LineChartView = {
        let deathsChartView = LineChartView()
        deathsChartView.rightAxis.enabled = false
        deathsChartView.xAxis.labelPosition = .bottom
        deathsChartView.legend.enabled = false
        deathsChartView.xAxis.labelFont = .systemFont(ofSize: 12)
        deathsChartView.xAxis.labelTextColor = .systemGray
        deathsChartView.leftAxis.labelFont = .systemFont(ofSize: 12)
        deathsChartView.leftAxis.labelTextColor = .systemGray
        deathsChartView.leftAxis.setLabelCount(4, force: true)
        deathsChartView.drawBordersEnabled = false
        deathsChartView.animate(xAxisDuration: 1.5)
        return deathsChartView
    }()
    
    //outlets voor containers
    @IBOutlet weak var casesChartContainer: UIView!
    @IBOutlet weak var deathsChartContainer: UIView!
    
    //variabele instantiatie
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var naam: String!
    var landcode: String!
    var totalCases = 0
    var totalDeaths = 0
    
    //outlets voor labels
    @IBOutlet weak var lblTotalCases: UILabel!
    @IBOutlet weak var lblTotalDeaths: UILabel!
    @IBOutlet weak var lblSeverity: UILabel!
    @IBOutlet weak var lblRatio: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.naam
        self.showData()
        self.fillCharts()
    }
    
    //vul charts met data
    func fillCharts(){
        //voeg chart toe aan container
        casesChartContainer.addSubview(casesChartView)
        casesChartView.width(to: casesChartContainer)
        casesChartView.height(to: casesChartContainer)
        
        //maak dataset en voeg toe aan chart
        let set = LineChartDataSet(entries: casesChartData, label: "Cases in " + self.naam)
        set.mode = .linear
        set.drawCirclesEnabled = false
        set.lineWidth = 3
        set.setColor(.systemBlue)
        set.fill = Fill(color: .systemBlue)
        set.fillAlpha = 0.5
        set.drawFilledEnabled = true
        //set.valueFont = .boldSystemFont(ofSize: 14)
        set.drawValuesEnabled = false
        let data = LineChartData(dataSet: set)
        casesChartView.data = data
        
        //voeg chart toe aan container
        deathsChartContainer.addSubview(deathsChartView)
        deathsChartView.width(to: deathsChartContainer)
        deathsChartView.height(to: deathsChartContainer)
        
        //maak dataset en voeg toe aan chart
        let setDeaths = LineChartDataSet(entries: deathsChartData, label: "Deaths in " + self.naam)
        setDeaths.mode = .linear
        setDeaths.drawCirclesEnabled = false
        setDeaths.lineWidth = 3
        setDeaths.setColor(.systemRed)
        setDeaths.fill = Fill(color: .systemRed)
        setDeaths.fillAlpha = 0.5
        setDeaths.drawFilledEnabled = true
        //set.valueFont = .boldSystemFont(ofSize: 14)
        setDeaths.drawValuesEnabled = false
        let dataDeaths = LineChartData(dataSet: setDeaths)
        deathsChartView.data = dataDeaths
    }
    
    //datasets
    var casesChartData: [ChartDataEntry] = []
    var deathsChartData: [ChartDataEntry] = []
    
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
        dataFetch.predicate = NSPredicate(format: "countriesAndTerritories == %@", self.naam)
        var opgehaaldeData:[CoronaData]
        
        let countryFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        countryFetch.predicate = NSPredicate(format: "name == %@", self.naam)
        var countryData:[Country]
        
        //fetch alle records van het huidige land
        do {
            try opgehaaldeData = try managedContext.fetch(dataFetch) as! [CoronaData]
            try countryData = try managedContext.fetch(countryFetch) as! [Country]
            var counter = 0
            //tel alle cases en deaths op
            for data in opgehaaldeData{
                totalCases += Int(data.cases!)!
                totalDeaths += Int(data.deaths!)!
            }
            
            //zet cases en deaths van laatste 7 dagen in de datasets
            for data in opgehaaldeData[0...6].reversed(){
                counter += 1
                casesChartData.append(ChartDataEntry(x: Double(counter), y: Double(data.cases!)!))
                deathsChartData.append(ChartDataEntry(x: Double(counter), y: Double(data.deaths!)!))
            }
            
            //toon totaal aantal cases en deaths, death/case ratio en severity
            self.lblTotalCases.text = formatter.string(from: NSNumber(value: totalCases))
            self.lblTotalDeaths.text = formatter.string(from: NSNumber(value: totalDeaths))
            
            let ratio = (Float(totalDeaths) / Float(totalCases)) * 100
            self.lblRatio.text = String(ratio).prefix(4) + "%"
            
            self.lblSeverity.text = countryData[0].severity!
            if(countryData[0].severity == "High"){
                self.lblSeverity.textColor = UIColor.systemRed
            } else if(countryData[0].severity == "Medium"){
                self.lblSeverity.textColor = UIColor.systemOrange
            } else{
                self.lblSeverity.textColor = UIColor.systemGreen
            }
        } catch {
            
        }
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
