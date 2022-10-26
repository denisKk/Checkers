//
//  ScoreTableViewCell.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 1.03.22.
//

import UIKit



class ShowAdsTableViewCell: UITableViewCell {
    @IBOutlet weak var showAsdSwitch: UISwitch!
    
    let settings = Settings.shared
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    @IBAction func swithValueChahanged(_ sender: Any) {
        settings.showAds = showAsdSwitch.isOn
    }
    
}


extension ShowAdsTableViewCell {
    private func setupUI(){
        showAsdSwitch.isOn = settings.showAds
    }
    
 
}
