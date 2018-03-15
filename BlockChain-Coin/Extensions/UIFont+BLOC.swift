//
//  UIFont+BLOC.swift
//  BlockChain-Coin
//
//  Created by Maxime Bornemann on 12/03/2018.
//  Copyright © 2018 BlockChain-Coin.net. All rights reserved.
//

import UIKit

extension UIFont {
    static func regular(size: CGFloat) -> UIFont {
        return R.font.robotoCondensedRegular(size: size)!
    }
    
    static func bold(size: CGFloat) -> UIFont {
        return R.font.robotoCondensedBold(size: size)!
    }
    
    static func light(size: CGFloat) -> UIFont {
        return R.font.robotoCondensedLight(size: size)!
    }
}
