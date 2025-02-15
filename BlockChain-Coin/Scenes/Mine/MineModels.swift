//
//  MineModels.swift
//  BlockChain-Coin
//
//  Created by Maxime Bornemann on 08/02/2018.
//  Copyright © 2018 BLOC.MONEY. All rights reserved.
//

import Foundation

struct PoolStatusViewModel {
    enum State {
        case disconnected
        case connected
        case connecting
        case error(String)
        
        var text: String {
            switch self {
            case .disconnected:
                return "Disconnected"
            case .connecting:
                return "Connecting"
            case .connected:
                return "Connected"
            case .error:
                return "Disconnected"
            }
        }
    }
    
    let state: State
    let address: String
    
    init(state: State, address: String?) {
        self.state = state
        self.address = address ?? "Tap \"Start Mining\" to begin"
    }
}

struct MinerStatsViewModel {
    let hashRate: Double
    let totalHashes: UInt64
    let sharesFound: UInt
}

struct OtherMinerStatsViewModel {
    let stats: PoolStatsModel
}

struct AddressMiningStatsViewModel {
    let stats: MiningAddressStatsModel
}

struct MineViewModel {
    let settings: MiningSettingsModel?
}
