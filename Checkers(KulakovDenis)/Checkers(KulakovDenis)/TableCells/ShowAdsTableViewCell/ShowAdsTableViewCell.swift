//
//  ScoreTableViewCell.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 1.03.22.
//

import UIKit



final class ShowAdsTableViewCell: UITableViewCell {
    @IBOutlet private var showAsdSwitch: UISwitch!
    @IBOutlet private var switchLabel: UILabel!
    
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
    
    func configure() {
        switchLabel.text = "hide Ads".localized
    }
 
}
