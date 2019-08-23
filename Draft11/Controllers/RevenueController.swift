//
//  RevenueController.swift
//  Draft11
//
//  Created by Sanket Ray on 8/22/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit
import PieCharts

class RevenueController: UIViewController, PieChartDelegate {

    @IBOutlet weak var pie: PieChart!
    
    var pool: Pool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        pie.layers = [createCustomViewsLayer(), createTextLayer()]
        pie.delegate = self
        pie.models = createModels() // order is important - models have to be set at the end
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            let slice = self.pie.slices[0]
            slice.view.selected = true
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - PieChartDelegate
    
    func onSelected(slice: PieSlice, selected: Bool) {
        print("Selected: \(selected), slice: \(slice)")
    }
    
    // MARK: - Models
    
    fileprivate func createModels() -> [PieSliceModel] {
        
        guard let pool = pool else { return [PieSliceModel]() }
        let winnersPercentage = Double(pool.totalWinningAmount) / Double(pool.entryFee * pool.totalSpots)
        print(winnersPercentage, "Winning Percentage 🎾" , pool.totalWinningAmount, pool.entryFee, pool.totalSpots)
        
        return [
            PieSliceModel(value: (1 - winnersPercentage), color: UIColor.draft11Red()),
            PieSliceModel(value: winnersPercentage, color: UIColor.rgb(0, 177, 57))
        ]
    }
    
    // MARK: - Layers
    
    fileprivate func createCustomViewsLayer() -> PieCustomViewsLayer {
        let viewLayer = PieCustomViewsLayer()
        
        let settings = PieCustomViewsLayerSettings()
        settings.viewRadius = 135
        settings.hideOnOverflow = true
        viewLayer.settings = settings
        
        viewLayer.viewGenerator = createViewGenerator()
        
        return viewLayer
    }
    
    fileprivate func createTextLayer() -> PiePlainTextLayer {
        let textLayerSettings = PiePlainTextLayerSettings()
        textLayerSettings.viewRadius = 60
        textLayerSettings.hideOnOverflow = true
        textLayerSettings.label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        textLayerSettings.label.textColor = .white
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        textLayerSettings.label.textGenerator = {slice in
            return formatter.string(from: slice.data.percentage * 100 as NSNumber).map{"\($0)%"} ?? ""
        }
        
        let textLayer = PiePlainTextLayer()
        textLayer.settings = textLayerSettings
        return textLayer
    }
    
    fileprivate func createViewGenerator() -> (PieSlice, CGPoint) -> UIView {
        return {slice, center in

            let container = UIView()
            container.frame.size = CGSize(width: 100, height: 40)
            container.center = center
            
            if slice.data.id == 0 {
                let specialTextLabel = UILabel()
                specialTextLabel.textAlignment = .center
                specialTextLabel.textColor = UIColor.draft11Red()
                specialTextLabel.text = "Draft11 Gross Margin"
                specialTextLabel.numberOfLines = 0
                specialTextLabel.font = UIFont.boldSystemFont(ofSize: 14)
                specialTextLabel.sizeToFit()
                specialTextLabel.frame = CGRect(x: 30, y: 0, width: 100, height: 40)
                container.addSubview(specialTextLabel)
                container.frame.size = CGSize(width: 100, height: 60)
                return container
            }
            
            return UIView()
        }
        
        
        
    }
}
