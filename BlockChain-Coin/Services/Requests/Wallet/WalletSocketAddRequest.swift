//
//  WalletSocketAddRequest.swift
//  BlockChain-Coin
//
//  Created by Maxime Bornemann on 13/02/2018.
//  Copyright © 2018 BlockChain-Coin.net. All rights reserved.
//

import UIKit
import JSONRPCKit
import APIKit

// curl -X POST localhost:8070/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"createAddress", "params":{ "spendPublicKey": "xxx" }}' -H 'Content-Type: application/json'
//
// {"id":"0","jsonrpc":"2.0","result":{"address":"xxx"}}
// {"error":{"code":-32000,"data":{"application_code":20},"message":"Address already exists"},"id":"0","jsonrpc":"2.0"}

struct CastError<ExpectedType>: Error {
    let actualValue: Any
    let expectedType: ExpectedType.Type
}

struct WalletRPCAddWalletRequest: JSONRPCKit.Request {
    typealias Response = String
    
    let publicKey: PublicKey

    var method: String {
        return "createAddress"
    }
    
    var parameters: Any? {
        return [ "spendPublicKey": publicKey.bytes.reduce("", { $0 + String(format: "%02x", $1) }) ]
    }
    
    func response(from resultObject: Any) throws -> Response {
        if let json = resultObject as? [String: Any], let response = json["address"] as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }

    }
}
