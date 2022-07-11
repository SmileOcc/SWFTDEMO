//
//  Array+Extensions.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/20.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation

extension Array{
    
    ///索引安全检查
    subscript(index:Int,safe:Bool)->Element?{
        if safe {
            if self.count > index {
                return self[index]
            }
            else {
                return nil
            }
        }
        else {
            return self[index]
        }
    }
}
