//
//  PremiersFilmTableViewCell.swift
//  Kinopoisk
//
//  Created by Dev on 21.02.22.
//

import UIKit

class BackgroundGradientTableViewCell: UITableViewCell {
    
    let gradientsArray: [(UIColor, UIColor)] = [
        (#colorLiteral(red: 0.04705882353, green: 0.7294117647, blue: 0.7294117647, alpha: 1), #colorLiteral(red: 0.2196078431, green: 0, blue: 0.2117647059, alpha: 1)),
        (#colorLiteral(red: 0.1568627451, green: 0.1921568627, blue: 0.231372549, alpha: 1), #colorLiteral(red: 0.2823529412, green: 0.3294117647, blue: 0.3803921569, alpha: 1)),
        (#colorLiteral(red: 0.05098039216, green: 0.1960784314, blue: 0.3019607843, alpha: 1), #colorLiteral(red: 0.4980392157, green: 0.3529411765, blue: 0.5137254902, alpha: 1)),
        (#colorLiteral(red: 0.1647058824, green: 0.3294117647, blue: 0.4392156863, alpha: 1), #colorLiteral(red: 0.2980392157, green: 0.2549019608, blue: 0.4666666667, alpha: 1)),
        (#colorLiteral(red: 0.1176470588, green: 0.231372549, blue: 0.4392156863, alpha: 1), #colorLiteral(red: 0.1607843137, green: 0.3254901961, blue: 0.6078431373, alpha: 1)),
        (#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.5725490196, green: 0.2352941176, blue: 0.7098039216, alpha: 1)),
        (#colorLiteral(red: 0.1725490196, green: 0.2431372549, blue: 0.3137254902, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
        (#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.6470588235, green: 0.3607843137, blue: 0.1058823529, alpha: 1)),
        (#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.9098039216, green: 0.262745098, blue: 0.5764705882, alpha: 1)),
        (#colorLiteral(red: 0.5843137255, green: 0.5568627451, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    ]
    
    var userClickGradient: (((UIColor, UIColor)) -> ())?
  
    @IBOutlet weak var collectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib.init(nibName: "BackgroundGradientCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BackgroundGradientCollectionViewCell")
    }
}


extension BackgroundGradientTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundGradientCollectionViewCell", for: indexPath) as? BackgroundGradientCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setup(with: gradientsArray[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gradientsArray.count
    }
}

extension BackgroundGradientTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 199)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        userClickGradient?(gradientsArray[indexPath.item])
    }
}
