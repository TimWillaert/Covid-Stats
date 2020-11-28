//
//  CountryMiniViewController.swift
//  Werkstuk
//
//  Created by student on 15/05/2020.
//  Copyright © 2020 Tim Willaert. All rights reserved.
//

import UIKit
import CoreData
import Charts
import TinyConstraints

class CountryMiniViewController: UIViewController {
    
    //chartview preparatie
    lazy var combinedChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.legend.enabled = true
        chartView.legend.form = .circle
        chartView.xAxis.labelFont = .systemFont(ofSize: 12)
        chartView.xAxis.labelTextColor = .systemGray
        chartView.leftAxis.labelFont = .systemFont(ofSize: 12)
        chartView.leftAxis.labelTextColor = .systemGray
        chartView.leftAxis.setLabelCount(4, force: true)
        chartView.drawBordersEnabled = false
        chartView.animate(xAxisDuration: 1.5)
        return chartView
    }()
    
    //variabele instantiatie
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var lblCountryName: UILabel!
    var countryName: String!
    var index = 0
    var totalCases = 0
    var totalDeaths = 0
    @IBOutlet weak var lblTotalCases: UILabel!
    @IBOutlet weak var lblTotalDeaths: UILabel!
    @IBOutlet weak var lblSeverity: UILabel!
    @IBOutlet weak var lblRatio: UILabel!
    @IBOutlet weak var graphContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblCountryName.text = countryName
        self.showData()
        self.fillChart()
    }
    
    //maak datasets en voeg toe aan chart
    func fillChart(){
        //voeg chart toe aan container
        graphContainer.addSubview(combinedChartView)
        combinedChartView.width(to: graphContainer)
        combinedChartView.height(to: graphContainer)
        
        let data = LineChartData()
        
        let set = LineChartDataSet(entries: casesChartData, label: "Cases")
        set.mode = .linear
        set.drawCirclesEnabled = false
        set.lineWidth = 3
        set.setColor(.systemBlue)
        set.valueFont = .boldSystemFont(ofSize: 10)
        set.drawValuesEnabled = false
        set.fill = Fill(color: .systemBlue)
        set.fillAlpha = 0.5
        set.drawFilledEnabled = true
        data.addDataSet(set)
        
        let setDeaths = LineChartDataSet(entries: deathsChartData, label: "Deaths")
        setDeaths.mode = .linear
        setDeaths.drawCirclesEnabled = false
        setDeaths.lineWidth = 3
        setDeaths.setColor(.systemRed)
        setDeaths.valueFont = .boldSystemFont(ofSize: 10)
        setDeaths.drawValuesEnabled = false
        setDeaths.fill = Fill(color: .systemRed)
        setDeaths.fillAlpha = 0.5
        setDeaths.drawFilledEnabled = true
        data.addDataSet(setDeaths)
        
        combinedChartView.data = data
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
        dataFetch.predicate = NSPredicate(format: "countriesAndTerritories == %@", self.countryName)
        var opgehaaldeData:[CoronaData]
        
        let countryFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        countryFetch.predicate = NSPredicate(format: "name == %@", self.countryName)
        var countryData:[Country]
        
        //fetch CoronaData en Country van relevante land
        do {
            try opgehaaldeData = try managedContext.fetch(dataFetch) as! [CoronaData]
            try countryData = try managedContext.fetch(countryFetch) as! [Country]
            
            //tel alle cases en deaths op
            for data in opgehaaldeData{
                totalCases += Int(data.cases!)!
                totalDeaths += Int(data.deaths!)!
            }
            
            //voeg cases en deaths toe aan dataset van laatste 7 dagen
            var counter = 0
            for data in opgehaaldeData[0...6].reversed(){
                counter += 1
                casesChartData.append(ChartDataEntry(x: Double(counter), y: Double(data.cases!)!))
                deathsChartData.append(ChartDataEntry(x: Double(counter), y: Double(data.deaths!)!))
            }
            
            //toon totaal aantal cases, deaths, death/case ratio en severity
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
