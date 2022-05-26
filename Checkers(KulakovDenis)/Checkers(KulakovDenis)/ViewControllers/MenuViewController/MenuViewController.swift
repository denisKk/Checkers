//
//  MenuViewController.swift
//  Checkers(kulakov)
//
//  Created by Dev on 8.02.22.
//

import UIKit
import GoogleMobileAds

class MenuViewController: UIViewController {
    
    @IBOutlet weak var startGameButton: UIView!
    @IBOutlet weak var scoreButton: UIView!
    @IBOutlet weak var settingsButton: UIView!
    @IBOutlet weak var infoButton: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    private var interstitial: GADInterstitialAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    func setupUI(){
        setupImageView()
        setupButtons()
    }
    
    func loadData(){
        userNameLabel.text = Settings.shared.userName
        avatarImageView.image = Settings.shared.avatar
        if let gradient = Settings.shared.gradientColor {
            if let view = self.view as? GradientBackgroundView {
                view.setGradientColor(gradient: gradient)
            }
        }
    }
    
    func goToGameViewController(){
        guard let vc = GameViewController.getInstanceViewController as? GameViewController
        else {return}
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToSettingsViewController(){
        guard let vc = SettingsViewController.getInstanceViewController as? SettingsViewController
        else {return}
        vc.modalPresentationStyle = .fullScreen
        vc.title = "Settings"
        navigationController?.present(vc, animated: true)
    }
    
    func goToScoreViewController(){
        guard let vc = ScoreViewController.getInstanceViewController as? ScoreViewController
        else {return}
        vc.modalPresentationStyle = .fullScreen
        vc.title = "Score"
        navigationController?.present(vc, animated: true)
    }
    
    func loadInterstitialView() {
        goToGameViewController()
//        self.view.showLoading()
//        let request = GADRequest()
//        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-3940256099942544/4411468910",
//                                    request: request,
//                          completionHandler: { [self] ad, error in
//                            if let error = error {
//                              print("Failed to load interstitial ad with error: \(error.localizedDescription)")
//                              return
//                            }
//                            interstitial = ad
//                            interstitial?.fullScreenContentDelegate = self
//
//                            interstitial?.present(fromRootViewController: self)
//                          }
//        )
    }
}

//MARK: Setup elements
extension MenuViewController {
    
    func setupImageView(){
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.layer.borderWidth = 3
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAvatarImageView(_:))))
    }
    
    func setupButtons(){
        startGameButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapStartGameButton)))
        
        settingsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSettingsButton)))
        
        scoreButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapScoreButton)))
    }
}

//MARK: Selectors and Actions
extension MenuViewController{
    @objc
    func tapStartGameButton(){
        
        if Settings.shared.chessArray != nil {
            let alert = UIAlertController(title: "Hello", message: "You have a saved game. Are you continue or start new game?", preferredStyle: .alert)
            let newGame = UIAlertAction(title: "New game", style: .cancel, handler: {_ in
                Settings.shared.resetData()
               // self.goToGameViewController()
                self.loadInterstitialView()
            })
            
            let continueGame = UIAlertAction(title: "Continue", style: .default) { _ in
               // self.goToGameViewController()
                self.loadInterstitialView()
            }
            
            alert.addAction(newGame)
            alert.addAction(continueGame)
            present(alert, animated: true, completion: nil)
        } else {
           // goToGameViewController()
            loadInterstitialView()
        }
    }
    
    @objc
    func tapSettingsButton(){
        goToSettingsViewController()
    }
    
    @objc
    func tapScoreButton(){
        goToScoreViewController()
    }
    
    @objc
    func tapAvatarImageView(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let changeAvatar = UIAlertAction(title: "Edit avatar", style: .default) { _ in
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)
        }
        
        alert.addAction(cancel)
        alert.addAction(changeAvatar)
        
        let removeAvatar = UIAlertAction(title: "Delete", style: .destructive) { _ in
            Settings.shared.avatar = nil
            self.avatarImageView.image = UIImage(named: "avatar")
        }
        
        if !Settings.shared.isEmptyAvatar  {
            alert.addAction(removeAvatar)
        }
        present(alert, animated: true, completion: nil)
    }
}

//MARK: Animations
extension MenuViewController {
    
    func hideElements(){
        
    }
}


extension MenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            Settings.shared.avatar = image
            avatarImageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension MenuViewController: GADFullScreenContentDelegate {
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
      print("Ad did fail to present full screen content.")
        self.view.closeLoading()
        goToGameViewController()
    }

    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad will present full screen content.")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad did dismiss full screen content.")
        self.view.closeLoading()
        goToGameViewController()
    }
}
