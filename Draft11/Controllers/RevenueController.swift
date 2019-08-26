//
//  RevenueController.swift
//  Draft11
//
//  Created by Sanket Ray on 8/22/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit
import PieCharts
import FirebaseDatabase

class RevenueController: UIViewController, PieChartDelegate {
    
    @IBOutlet weak var pie: PieChart!
    
    var pool: Pool?
    var reference: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reference = Database.database().reference()
        
        refreshTheContest()
    }
    
    fileprivate func refreshTheContest() {
        
        guard let pool = pool else { return }
        reference.child("Pools").child(pool.id).child("players").removeValue()
        reference.child("Pools").child(pool.id).updateChildValues(["isContestLive": false, "spotsLeft": pool.totalSpots])
        
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
    
    fileprivate func createCustomViewsLayer() -> PieCustomViewsLayer {
        let viewLayer = PieCustomViewsLayer()
        
        let settings = PieCustomViewsLayerSettings()
        settings.viewRadius = 135
        settings.hideOnOverflow = false
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


/*
 
 @IBOutlet weak var textLabel1: UILabel!
 @IBOutlet weak var textLabel2: UILabel!
 var attributedString: NSAttributedString?
 var numWhiteCharacters = 0
 var topLabel: UILabel?
 var bottomLabel: UILabel?
 
 func viewDidLoad() {
 super.viewDidLoad()
 
 textLabel1.alpha = 0
 textLabel2.alpha = 0
 
 // this is based on the view hierarchy in the storyboard
 topLabel = textLabel2
 bottomLabel = textLabel1
 
 let mySecretMessage = "This is a my replication of Secret's text animation. It looks like one fancy label, but it's actually two UITextLabels on top of each other! What do you think?"
 
 numWhiteCharacters = 0
 
 let initialAttributedText = randomlyFadedAttributedString(from: mySecretMessage)
 topLabel.attributedText = initialAttributedText
 
 weak var weakSelf = self
 UIView.animate(withDuration: 0.1, animations: {
 weakSelf?.topLabel.alpha = 1
 }) { finished in
 if let randomly = weakSelf?.randomlyFadedAttributedString(from: initialAttributedText) {
 weakSelf?.attributedString() = randomly
 }
 weakSelf?.bottomLabel.attributedText = weakSelf?.attributedString()
 weakSelf?.performAnimation()
 }
 }
 
 func performAnimation() {
 weak var weakSelf = self
 UILabel.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
 weakSelf?.bottomLabel.alpha = 1
 }) { finished in
 weakSelf?.resetLabels()
 
 // keep performing the animation until all letters are white
 if weakSelf?.numWhiteCharacters == weakSelf?.attributedString().length {
 weakSelf?.bottomLabel.removeFromSuperview()
 } else {
 weakSelf?.performAnimation()
 }
 }
 }
 
 func resetLabels() {
 topLabel.removeFromSuperview()
 topLabel.alpha = 0
 
 // recalculate attributed string with the new white color values
 attributedString = randomlyFadedAttributedString(from: attributedString)
 topLabel.attributedText = attributedString
 
 view.insertSubview(topLabel, belowSubview: bottomLabel)
 
 //  the top label is now on the bottom, so switch
 let oldBottom = bottomLabel
 let oldTopLabel = topLabel
 
 bottomLabel = oldTopLabel
 topLabel = oldBottom
 }
 
 func randomlyFadedAttributedString(from string: String?) -> NSAttributedString? {
 var attributedString = NSMutableAttributedString(string: string ?? "")
 
 for i in 0..<(string?.count ?? 0) {
 let color = whiteColor(withClearColorProbability: 10)
 attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: i, length: 1))
 updateNumWhiteCharacters(for: color)
 }
 
 return attributedString
 }

 func randomlyFadedAttributedString(from attributedString: NSAttributedString?) -> NSAttributedString? {
 var mutableAttributedString = attributedString as? NSMutableAttributedString
 
 weak var weakSelf = self
 for i in 0..<(attributedString?.length ?? 0) {
 attributedString?.enumerateAttribute(.foregroundColor, in: NSRange(location: i, length: 1), options: .longestEffectiveRangeNotRequired, using: { value, range, stop in
 let initialColor = value as? UIColor
 let newColor = weakSelf?.whiteColor(fromInitialColor: initialColor)
 if newColor != nil {
 mutableAttributedString?.addAttribute(.foregroundColor, value: newColor, range: range)
 weakSelf?.updateNumWhiteCharacters(for: newColor)
 }
 })
 }
 
 return mutableAttributedString
 }
 
 func updateNumWhiteCharacters(for color: UIColor?) {
 let alpha = CGColorGetAlpha(color?.cgColor)
 if alpha == 1.0 {
 numWhiteCharacters += 1
 }
 }
 
 
 */
