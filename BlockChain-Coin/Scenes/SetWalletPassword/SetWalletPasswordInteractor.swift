//  
//  SetWalletPasswordInteractor.swift
//  BlockChain-Coin
//
//  Created by Maxime Bornemann on 15/03/2018.
//  Copyright © 2018 BLOC.MONEY. All rights reserved.
//

import Foundation

protocol SetWalletPasswordBusinessLogic {
    var presenter: SetWalletPasswordPresentationLogic? { get set }
    
    func validateForm(request: SetWalletPasswordRequest)
    func setPassword(request: SetWalletPasswordRequest)
}

class SetWalletPasswordInteractor: SetWalletPasswordBusinessLogic {
    var presenter: SetWalletPasswordPresentationLogic?
    
    let localWalletWorker: WalletWorker!
    var remoteWalletWorker: WalletWorker!

    init() {
        localWalletWorker = WalletWorker(store: WalletDiskStore())
        remoteWalletWorker = WalletWorker(store: WalletAPI())
    }
    
    func setPassword(request: SetWalletPasswordRequest) {
        presenter?.handleShowLoading()
        
        if let seed = localWalletWorker.generateSeed(), let keyPair = localWalletWorker.generateKeyPair(seed: seed) {
            let uuid = UUID()
            
            remoteWalletWorker.addWallet(keyPair: keyPair, uuid: uuid, secretKey: nil, password: nil, address: nil, name: request.form.name ?? "", details: nil, completion: { [weak self] result in
                switch result {
                case .success(let address):
                    let wallet = Wallet(uuid: uuid, keyPair: keyPair, address: address, password: request.form.password ?? "", name: request.form.name ?? "", details: nil, createdAt: Date())

                    self?.remoteWalletWorker.getBalanceAndTransactions(wallet: wallet, password: wallet.password ?? "", completion: { detailsResult in
                        switch detailsResult {
                        case .success(let details):
                            self?.localWalletWorker.addWallet(keyPair: keyPair, uuid: uuid, secretKey: nil, password: request.form.password, address: address, name: request.form.name ?? "", details: details, completion: { localResult in
                                switch localResult {
                                case .success:
                                    log.info("New wallet created: \(address)")
                                    let wallet = Wallet(uuid: uuid, keyPair: keyPair, address: address, password: request.form.password ?? "", name: request.form.name ?? "", details: details, createdAt: Date())
                                    self?.presenter?.handleWalletCreated(response: SetWalletPasswordResponse(wallet: wallet))
                                case .failure:
                                    self?.presenter?.handleShowError(error: .couldNotCreateWallet)
                                }
                            })
                        case .failure:
                            self?.presenter?.handleShowError(error: .couldNotCreateWallet)
                        }
                    })
                case .failure:
                    self?.presenter?.handleShowError(error: .couldNotCreateWallet)
                }
            })
        } else {
            presenter?.handleShowError(error: .couldNotCreateWallet)
        }
    }
    
    func validateForm(request: SetWalletPasswordRequest) {
        presenter?.handleFormIsValid(valid: request.form.isValid)
    }
}
