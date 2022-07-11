//
//  YXV2QuoteService.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2019/8/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import NSObject_Rx

public protocol HasYXV2QuoteService {
    var v2QuoteService: YXV2QuoteService { get }
}

@objcMembers public class YXV2QuoteService: NSObject, YXRequestable {
    
    public typealias API = YXV2QuotesDataAPI
    
    public var networking: MoyaProvider<API> {
        return v2quoteProvider
    }
    
    public override init() { }
    
    public func unSubOptional(with quoteRequests: [YXQuoteRequest]?) {
        quoteRequests?.forEach { (request) in
            request.cancel()
        }
    }
    
    public func subOptional(with secus: [Secu],
                         quoteSubject: PublishSubject<([YXV2Quote],Scheme)>,
                         timeLineSubject: PublishSubject<[YXBatchTimeLine]>, allHKSecus: [Secu] = []) -> [YXQuoteRequest] {
        
        //期权订阅单独处理
        var normalSecus = [Secu]() // 普通股票
        var options = [Secu]() // 期权
        var usIndexs = [Secu]() // 美股指数
        for secu in secus {
            if secu.market == "usoption" {
                options.append(secu)
            } else {
                normalSecus.append(secu)
            }
        }
        
        let levelSecus = LevelSecus(secus: normalSecus, allHKSecus: allHKSecus)
        
        var quoteRequests = [YXQuoteRequest]()
        
        for i in 0..<6 {
            var array = [Secu]()
            var level = QuoteLevel.delay
            
            switch i {
            case 0:
                array = levelSecus.delay
                level = .delay
            case 1:
                array = levelSecus.bmp
                level = .bmp
            case 2:
                array = levelSecus.level1
                level = .level1
            case 3:
                array = levelSecus.level2
                level = .level2
            case 4:
                array = levelSecus.none
                level = .none
            case 5:
                array = levelSecus.usNation
                level = .usNational
            default:
                break
            }
            
            if array.count > 0 {
                let request = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: array, level: level, handler: { (list, scheme) in
                    quoteSubject.onNext((list,scheme))
                })
                quoteRequests.append(request)
                
                let timeLineRequest = YXQuoteManager.sharedInstance.subBatchTimeLine(secus: array, level: level, handler: { (list) in
                    timeLineSubject.onNext(list)
                })
                quoteRequests.append(timeLineRequest)
            }
        }
        
        if options.count > 0, YXUserHelper.currentUSOptionLevel() == .usLevel1 {
            let request = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: options, level: .level1, handler: { (list, scheme) in
                quoteSubject.onNext((list,scheme))
            })
            quoteRequests.append(request)
            
            let timeLineRequest = YXQuoteManager.sharedInstance.subBatchTimeLine(secus: options, level: .level1, handler: { (list) in
                timeLineSubject.onNext(list)
            })
            quoteRequests.append(timeLineRequest)
        }
        
        return quoteRequests
    }
    
}

public let usIndexSymbols = [".DJI", ".SPX", ".IXIC"]

@objcMembers public class LevelSecus: NSObject {
    public var none = [Secu]()
    public var delay = [Secu]()
    public var bmp = [Secu]()
    public var level2 = [Secu]()
    public var level1 = [Secu]()
    public var usNation = [Secu]()
    
    @objc public convenience init(secus: [Secu], allHKSecus: [Secu] = []) {
        self.init()
        
        let usLevel = YXUserHelper.currentUsLevel()
        let hkLevel = YXUserHelper.currentHkLevel()
        let cnLevel = YXUserHelper.currentCnLevel()
        let usIndexLevel = YXUserHelper.currentUSIndexLevel()
        let sgLevel = YXUserHelper.currentSGLevel()
        
        var moreThan20Secus = [Secu]()
        if hkLevel == .hkBMP {
            if allHKSecus.count > 20 {
                for index in 20..<allHKSecus.count {
                    moreThan20Secus.append(allHKSecus[index])
                }
            }
        }
        
        func isInMoreThan20Secu(secu: Secu) -> Bool {
            for s in moreThan20Secus {
                if s == secu {
                    return true
                }
            }
            return false
        }
        
        secus.forEach { (secu) in
            if secu.market == "us" {
                if usIndexSymbols.contains(secu.symbol) {
                    switch usIndexLevel {
                    case .usLevel1:
                        level1.append(secu)
                    case .none:
                        none.append(secu)
                    default:
                        break
                    }
                } else {
                    switch usLevel {
                    case .usDelay:
                        delay.append(secu)
                    case .usLevel1:
                        level1.append(secu)
                    case .usNation:
                        usNation.append(secu)
                    default:
                        delay.append(secu)
                        break
                    }
                }
            }
            
            if secu.market == "hk" {
                switch hkLevel {
                case .hkDelay:
                    delay.append(secu)
                case .hkBMP:
                    if bmp.count < 20, !isInMoreThan20Secu(secu: secu) {
                        bmp.append(secu)
                    } else {
                        delay.append(secu)
                    }
                case .hkLevel1:
                    level1.append(secu)
                case .hkLevel2,
                     .hkWorldLevel2:
                    level2.append(secu)
                default:
                    delay.append(secu)
                    break
                }
            }
            
            if secu.market == "sg" {
                switch sgLevel {
                case .sgDelay:
                    delay.append(secu)
                case .sgLevel1Overseas,
                     .sgLevel1CN:
                    level1.append(secu)
                case .sgLevel2Overseas,
                     .sgLevel2CN:
                    level2.append(secu)
                default:
                    delay.append(secu)
                    break
                }
            }
            
            if secu.market == "sh" || secu.market == "sz" {
                switch cnLevel {
                case .cnDelay:
                    delay.append(secu)
                case .cnLevel1:
                    level1.append(secu)
                default:
                    delay.append(secu)
                    break
                }
            }
        }
    }
}
