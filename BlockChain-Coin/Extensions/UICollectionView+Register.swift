//
//  UICollectionView+Register.swift
//  BlockChain-Coin
//
//  Created by Maxime Bornemann on 21/03/2018.
//  Copyright © 2018 BLOC.MONEY. All rights reserved.
//

import UIKit

extension UICollectionViewCell: Reusable {
    
    static func registerWith(_ collectionView: UICollectionView) {
        collectionView.register(self, forCellWithReuseIdentifier: self.reuseIdentifier())
    }
}
