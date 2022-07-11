//
//  URLExtension.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/12/14.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

extension URL {
    var queryDictionary: [String: String]? {
        guard let query = self.query else {
            return nil
        }
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            let key = pair.components(separatedBy: "=")[0]
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            queryStrings[key] = value
        }
        return queryStrings
    }
}
