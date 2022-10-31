//
//  ScoreViewController.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 1.03.22.
//

import UIKit

final class ScoreViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var dataArray: [GameHistory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 135
        tableView.register(UINib(nibName: String(describing: ScoreTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ScoreTableViewCell.self))
        dataArray = CoreDataManager.shared.getAllGamesDB()
    }

    @IBAction func closeButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: Setup elements
extension ScoreViewController {
    func setupUI() {
        if let gradient = Settings.shared.gradientColor {
            if let view = self.view as? GradientBackgroundView {
                view.setGradientColor(gradient: gradient)
            }
        }
        
        
    }
}


extension ScoreViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ScoreTableViewCell.self), for: indexPath) as? ScoreTableViewCell else {
            return UITableViewCell()
        }
        cell.setup(with: dataArray[indexPath.row])
        return cell
    }
}
