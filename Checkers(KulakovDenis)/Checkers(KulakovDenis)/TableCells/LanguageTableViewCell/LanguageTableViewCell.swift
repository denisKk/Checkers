//
//  LanguageTableViewCell.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 29.06.22.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    let dataArray = Settings.shared.languageCodes
    var userClickLanguage: ((String) -> ())?

    func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib.init(nibName: "LanguageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LanguageCollectionViewCell")
    }
}


extension LanguageTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LanguageCollectionViewCell", for: indexPath) as? LanguageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let isBorder = Settings.shared.currentLanguageCode == dataArray[indexPath.item]
        cell.setup(with: dataArray[indexPath.item], bordered: isBorder)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
}

extension LanguageTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        userClickLanguage?(dataArray[indexPath.item])
        collectionView.reloadData()
    }
}
