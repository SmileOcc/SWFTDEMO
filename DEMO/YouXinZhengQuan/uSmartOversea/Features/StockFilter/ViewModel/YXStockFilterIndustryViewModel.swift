//
//  YXStockFilterIndustryViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator
import YXKit


class YXStockFilterIndustryViewModel: HUDServicesViewModel {

    typealias Services = HasYXInformationService & HasYXNewsService & HasYXQuotesDataService

    var disposeBag = DisposeBag.init()
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var navigator: NavigatorServicesType!


    var market: String = "hk"
    var industryItem: YXStockFilterItem?
    var didSelectedAction: ((_ item: YXStockFilterItem, _ selecteds: [Any]) -> Void)?

    var selectItems: [Any] = []

    var totalIndustryDic: Dictionary<String, Any> = [:]

    var dataSource = [[Any]]()
    var titleArr: [String] = []

    var services: Services! {
        didSet {

        }
    }

    func isSelectItem(_ item: Any) -> Bool {

        var isFind = false
        if let dic = item as? [String : Any] {
            if let industryCode = dic["industry_code_yx"] as? String {

                for obj in selectItems {
                    if let tempDic = obj as? [String : Any], let code = tempDic["industry_code_yx"] as? String, code == industryCode {

                        isFind = true
                        break
                    }
                }
            }
        }

        return isFind
    }


    func handleSelectItem(_ item: Any) {

        if let dic = item as? [String : Any] {
            if let industryCode = dic["industry_code_yx"] as? String {

                var isFind = false
                var index = 0
                for (i, obj) in selectItems.enumerated() {
                    if let tempDic = obj as? [String : Any], let code = tempDic["industry_code_yx"] as? String, code == industryCode {

                        isFind = true
                        index = i;
                        break
                    }
                }

                if isFind {
                    self.selectItems.remove(at: index)
                } else {
                    self.selectItems.append(item)
                }

            }
        }
    }


    func filterIndustryDic(_ filterString: String) {

        if filterString.isEmpty {
            self.parseDataSource(self.totalIndustryDic)
        } else {
            var filterDic: [String : Any] = [:]
            for (key, value) in self.totalIndustryDic {

                var filterArr: [[String : Any]] = []
                if let arr = value as? [[String : Any]] {
                    for obj in arr {
                        if let value = obj["industry_pinyin"] as? String, value.contains(filterString.lowercased()) {
                            filterArr.append(obj)
                        } else if let value = obj["industry_name"] as? String, value.contains(filterString) {
                            filterArr.append(obj)
                        }  else if let value = obj["industry_code_yx"] as? String, value.contains(filterString) {
                            filterArr.append(obj)
                        }
                    }
                }

                if filterArr.count > 0 {
                    filterDic[key] = filterArr
                }
            }

            self.parseDataSource(filterDic)
        }

    }


    func parseIndustryData() {

        let data = MMKV.default().data(forKey: "industryListPath")

        if let data = data {
            let dic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)

            var languageKey = "en"
            if YXUserManager.isENMode() {
                languageKey = "en"
            } else if YXUserManager.curLanguage() == .CN {
                languageKey = "cn"

            } else {
                languageKey = "tc"
            }


            var markeKey = "a"
            if self.market == YXMarketType.HK.rawValue {
                markeKey = YXMarketType.HK.rawValue
            } else if self.market == YXMarketType.US.rawValue {
                markeKey = YXMarketType.US.rawValue
            } else {
                markeKey = "a"
            }

            if let dic = dic as? Dictionary<String, Any> {
                if let languageDic = dic[languageKey] as? Dictionary<String, Any> {
                    //先根据语言找
                    if let aDic = languageDic[markeKey] as? Dictionary<String, Any> {
                        //再根据市场找
                        if let result = aDic["map"] as? Dictionary<String, Any> {

                            self.totalIndustryDic = result
                            self.parseDataSource(result)
                        }
                    }
                }
            }
        }
    }


    func parseDataSource(_ result: Dictionary<String, Any>) {

        let dic = result.sorted { (obj1, obj2) -> Bool in

            let key1 = NSString(string: obj1.key)
            let key2 = NSString(string: obj2.key)

            return key1.character(at: 0) < key2.character(at: 0)

        }

        self.dataSource.removeAll()

        var contentArr = [[Any]]()
        var tempTitles: [String] = []

        for (key, value) in dic {
            tempTitles.append(key)
            var subContentArr = [Any]()
            if let arr = value as? [Any] {
                for obj in arr {
                    subContentArr.append(obj)
                }
            }
            contentArr.append(subContentArr)
        }
        self.titleArr = tempTitles
        self.dataSource = contentArr
    }


}
