//
//  API.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Moya
import YXKit

let multiProvider = MoyaProvider<MultiTarget>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])
