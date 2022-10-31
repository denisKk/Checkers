//
//  MenuViewController.swift
//  Checkers(kulakov)
//
//  Created by Dev on 8.02.22.
//

import UIKit
import GoogleMobileAds

final class MenuViewController: UIViewController {

    @IBOutlet private var startGameButton: BorderButton!
    @IBOutlet private var scoreButton: BorderButton!
    @IBOutlet private var settingsButton: BorderButton!
    @IBOutlet private var infoButton: BorderButton!
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var avatarImageView: UIImageView!

    private var interstitial: GADInterstitialAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupActions()
        setupImageView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return true
    }

    func setupUI() {
        setupButtons()
        setupAvatarCornerRadius()
        if let gradient = Settings.shared.gradientColor {
            if let view = self.view as? GradientBackgroundView {
                view.setGradientColor(gradient: gradient)
            }
        }
    }

    func loadData() {
        userNameLabel.text = Settings.shared.userName
        avatarImageView.image = Settings.shared.avatar
    }

    @IBAction func logoutButtonTap(_ sender: Any) {
        Settings.shared.logOut()
        CoreDataManager.shared.clearDataBase()
        guard let startVC = StartViewController.getInstanceViewController as? StartViewController
        else {return}

        UIApplication.shared.windows.first?.rootViewController = startVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

    func goToGameViewController() {
        guard let vc = GameViewController.getInstanceViewController as? GameViewController
        else {return}
        navigationController?.pushViewController(vc, animated: true)
    }

    func goToSettingsViewController() {
        guard let vc = SettingsViewController.getInstanceViewController as? SettingsViewController
        else {return}
        vc.modalPresentationStyle = .fullScreen
        navigationController?.present(vc, animated: true)
    }

    func goToScoreViewController() {
        guard let vc = ScoreViewController.getInstanceViewController as? ScoreViewController
        else {return}
        vc.modalPresentationStyle = .fullScreen
        navigationController?.present(vc, animated: true)
    }

    func goToPropertyViewController() {
        guard let vc = PropertyViewController.getInstanceViewController as? PropertyViewController
        else {return}
        navigationController?.pushViewController(vc, animated: true)
    }

    func loadInterstitialView() {

        guard !Settings.shared.showAds else {
            goToNextViewController()
            return
        }

        self.view.showLoading()
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910",
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self

            interstitial?.present(fromRootViewController: self)
        }
        )
    }

    func goToNextViewController() {
        if Settings.shared.chessArray != nil {
            goToGameViewController()
        } else {
            goToPropertyViewController()
        }
    }
}

// MARK: Setup elements
extension MenuViewController {

    func setupAvatarCornerRadius() {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }

    func setupImageView() {
        avatarImageView.clipsToBounds = true
//        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.layer.borderWidth = 3
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(tapAvatarImageView(_:))))
    }

    func setupButtons() {
        startGameButton.caption = "Two players".localized
        scoreButton.caption = "History".localized
        settingsButton.caption = "Settings".localized
        infoButton.caption = "Info".localized
    }

    func setupActions() {
        startGameButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(tapStartGameButton)))

        settingsButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(tapSettingsButton)))

        scoreButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(tapScoreButton)))
    }
}

// MARK: Selectors and Actions
extension MenuViewController {
    @objc
    func tapStartGameButton() {

        guard Settings.shared.chessArray != nil  else {
            loadInterstitialView()
            return
        }

        let alert = UIAlertController(
            title: "Hello".localized,
            message: "You have a saved game. Are you continue or start new game?".localized,
            preferredStyle: .alert)
        let newGame = UIAlertAction(title: "New game".localized, style: .cancel, handler: {_ in
            Settings.shared.resetData()
            self.loadInterstitialView()
        })

        let continueGame = UIAlertAction(title: "Continue".localized, style: .default) { _ in
            self.loadInterstitialView()
        }

        alert.addAction(newGame)
        alert.addAction(continueGame)
        present(alert, animated: true, completion: nil)

    }

    @objc
    func tapSettingsButton() {
        goToSettingsViewController()
    }

    @objc
    func tapScoreButton() {
        goToScoreViewController()
    }

    @objc
    func tapAvatarImageView(_ sender: Any) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)

        let changeAvatar = UIAlertAction(title: "Edit avatar".localized, style: .default) { _ in
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)
        }

        alert.addAction(cancel)
        alert.addAction(changeAvatar)

        let removeAvatar = UIAlertAction(title: "Delete".localized, style: .destructive) { _ in
            Settings.shared.avatar = nil
            self.avatarImageView.image = UIImage(named: "avatar")
        }

        if !Settings.shared.isEmptyAvatar {
            alert.addAction(removeAvatar)
        }
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Animations

extension MenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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
       // print("Ad did fail to present full screen content.")
        self.view.closeLoading()
        goToNextViewController()
    }

    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      //  print("Ad will present full screen content.")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      //  print("Ad did dismiss full screen content.")
        self.view.closeLoading()
        goToNextViewController()
    }
}
