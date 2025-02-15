//  
//  WalletSettingsRouter.swift
//  BlockChain-Coin
//
//  Created by Maxime Bornemann on 20/03/2018.
//  Copyright © 2018 BLOC.MONEY. All rights reserved.
//

import UIKit

protocol WalletSettingsRoutingLogic {
    func goBack()
    func showExportWallet(wallet: WalletModel)
    func showDeleteWallet(wallet: WalletModel)
}

class WalletSettingsRouter: Router, WalletSettingsRoutingLogic {
    weak var viewController: UIViewController?
    
    func goBack() {
        viewController?.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func showExportWallet(wallet: WalletModel) {
        let vc = ExportWalletKeysVC(wallet: wallet, mode: .export)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showDeleteWallet(wallet: WalletModel) {
        let vc = DeleteWalletVC(wallet: wallet)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

