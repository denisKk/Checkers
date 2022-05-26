//
//  ScoreViewController.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 1.03.22.
//

import UIKit

class ScoreViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let scoreArray: [ScoreItem] = [
        ScoreItem(whitePlayerName: "August Frazier", blackPlayerName: "Dean Knowles", date: "20 June 2021", time: "23:12", isWhiteWin: true),
        ScoreItem(whitePlayerName: "Leo Wilder", blackPlayerName: "Arnold Pollard", date: "17 Feb 2022", time: "05:01", isWhiteWin: false),
        ScoreItem(whitePlayerName: "Harold Reese", blackPlayerName: "Joseph Harmon", date: "1 Jan 2022", time: "12:30", isWhiteWin: false),
        ScoreItem(whitePlayerName: "Troy Woodward", blackPlayerName: "Sean Duncan", date: "5 Sep 2021", time: "00:23", isWhiteWin: true)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ScoreTableViewCell", bundle: nil), forCellReuseIdentifier: "ScoreTableViewCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
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
        return scoreArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreTableViewCell", for: indexPath) as? ScoreTableViewCell else {
            return UITableViewCell()
        }
        cell.setup(with: scoreArray[indexPath.row])
        return cell
    }
    
    
}

extension ScoreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
}
