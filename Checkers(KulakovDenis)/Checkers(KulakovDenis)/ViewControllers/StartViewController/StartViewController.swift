//
//  ViewController.swift
//  Checkers(kulakov)
//
//  Created by Dev on 28.01.22.
//

import UIKit



class StartViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var userNameTextFied: UITextField!
    @IBOutlet weak var enterButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Settings.shared.userName != nil {
            hideElements()
        } else {
            setupUI()
        }
    }
    
    func setupUI(){
        setupTextField()
        setupButtons()
        setupScrollView()
    }
    
    
    func saveUserName(){
        if let name = userNameTextFied.text {
            Settings.shared.userName = name
        }
    }
    
    func goToMenuViewController(){
        guard let menuVC = MenuViewController.getInstanceViewController as? UINavigationController
        else {return}

        UIApplication.shared.windows.first?.rootViewController = menuVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}

//MARK: Setup elements
extension StartViewController {
    
    func setupScrollView(){
        scrollView.delegate = self
    }
    
    func setupButtons(){
        enterButton.isUserInteractionEnabled = true
        enterButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapEnterButton)))
    }
    
    func setupTextField(){
        userNameTextFied.delegate = self
        userNameTextFied.simpleModifier()
    }
}

//MARK: Selectors and Actions
extension StartViewController{
    @objc
    func tapEnterButton(){
        saveUserName()
        hideElements()
    }
    
}

//MARK: Animations
extension StartViewController {
    
    func hideElements(){
//        scrollView.subviews.forEach({$0.hideAnimation()})
       // pageControl.hideAnimation()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.goToMenuViewController()
//        }
    }
}


//MARK: Delegates
extension StartViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty {
            enterButton.isEnabled = false
        } else {
            enterButton.isEnabled = true
        }
    }
    
}


extension StartViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let onePageWidth = scrollView.contentSize.width / CGFloat(pageControl.numberOfPages)
        pageControl.currentPage = Int(scrollView.contentOffset.x / onePageWidth)
    }
    
}
