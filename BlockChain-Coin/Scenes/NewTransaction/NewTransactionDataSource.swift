//
//  NewTransactionDataSource.swift
//  BlockChain-Coin
//
//  Created by Maxime Bornemann on 21/03/2018.
//  Copyright © 2018 BLOC.MONEY. All rights reserved.
//

import UIKit

class NewTransactionDataSource: ArrayDataSource {
    var availableWallets: [WalletModel] = []
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = items.first?.count ?? 0
        
        if count == 0 {
            return 1
        }
        
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let count = items.first?.count ?? 0

        if count == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: NewTransactionNoWalletCell.reuseIdentifier(), for: indexPath) as! NewTransactionNoWalletCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewTransactionWalletCell.reuseIdentifier(), for: indexPath) as! NewTransactionWalletCell
        
        if let wallet = items[indexPath.section][indexPath.row] as? WalletModel {
            cell.configure(name: wallet.name, amount: Double(wallet.details?.availableBalance ?? 0) / Constants.walletCurrencyDivider)
        }
        
        return cell
    }
}
