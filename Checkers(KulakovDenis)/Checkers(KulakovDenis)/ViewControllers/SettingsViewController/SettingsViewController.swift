//
//  SettingsViewController.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 25.02.22.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userClickGradient: (((UIColor, UIColor)) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "BackgroundGradientTableViewCell", bundle: nil), forCellReuseIdentifier: "BackgroundGradientTableViewCell")
        
        loadData()
        
        userClickGradient = { (gradient) in
            if let view = self.view as? GradientBackgroundView {
                view.setGradientColor(gradient: gradient)
            }
            Settings.shared.gradientColor = gradient
        }
    }

    
    @IBAction func closeButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BackgroundGradientTableViewCell", for: indexPath) as? BackgroundGradientTableViewCell else {
            return UITableViewCell()
        }
        cell.userClickGradient = userClickGradient
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Background Gradients"
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
        return 200
    }
}
