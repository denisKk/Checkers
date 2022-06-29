//
//  SettingsViewController.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 25.02.22.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var userClickGradient: (((UIColor, UIColor)) -> ())?
    var userClickLanguage: ((String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "BackgroundGradientTableViewCell", bundle: nil), forCellReuseIdentifier: "BackgroundGradientTableViewCell")
        tableView.register(UINib(nibName: "LanguageTableViewCell", bundle: nil), forCellReuseIdentifier: "LanguageTableViewCell")
        
        loadData()
        
        userClickGradient = { [weak self] (gradient) in
            if let view = self?.view as? GradientBackgroundView {
                view.setGradientColor(gradient: gradient)
            }
            Settings.shared.gradientColor = gradient
            self?.tableView.reloadData()
        }
        
        userClickLanguage = { languageCode in
            Settings.shared.currentLanguageCode = languageCode
            self.tableView.reloadData()
            self.setupUI()
        }
    }

    
    @IBAction func closeButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupUI(){
        titleLabel.text = "Settings".localized
    }
    
    func loadData(){
        if let gradient = Settings.shared.gradientColor {
            if let view = self.view as? GradientBackgroundView {
                view.setGradientColor(gradient: gradient)
            }
        }
    }
}


//MARK: TableView Delegate
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BackgroundGradientTableViewCell", for: indexPath) as? BackgroundGradientTableViewCell else {
                return UITableViewCell()
            }
            cell.userClickGradient = userClickGradient
            if let view = self.view as? GradientBackgroundView, let startColor = view.startColor, let endColor = view.endColor {
                cell.viewGradient = (startColor, endColor)
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableViewCell", for: indexPath) as? LanguageTableViewCell else {
                return UITableViewCell()
            }
            cell.userClickLanguage = userClickLanguage
            return cell
        default: return UITableViewCell()
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Background Gradients".localized
        case 1: return "Languages".localized
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .white
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .white
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1: return 50
        default:
            return 200
        }
    }
}
