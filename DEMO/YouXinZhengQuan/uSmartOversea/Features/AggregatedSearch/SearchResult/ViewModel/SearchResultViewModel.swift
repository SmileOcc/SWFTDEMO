//
//  SearchResultViewModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/2/28.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

protocol SearchTypeBase {
    var title: String { get }
    var requestParams: [Int] { get }
}

// 搜索类型接口传参值
enum YXSearchTypeParam: Int {
    case quote = 1  // 行情
    case fund = 2   // 基金
    case strategy = 3 // 策略
    case news = 4 // 资讯
    case post = 5 // 帖子
    case live = 6 // 直播
    case kol = 7  // 认证用户
    case help = 8 // 帮助
    case beerichLive = 101 // beerich直播
    case beerichShortVideo = 102 // beerich短视频
    case beeRichAsk = 103 // beerich问股
    case beerichView = 104 // beerich观点
    case beeRichChat = 105 // beerich聊天群组
    case beerichMaster = 106 // beerich大咖
    case beerichCourse = 107 // beerich课程
}

enum SearchType: SearchTypeBase {
    case all                                        // 全部
    case quote                                      // 行情
    case strategy                                   // 理财
    case news                                       // 资讯
    case community(_ subType: SearchCommunityType)  // 社区
    case help                                       // 帮助

    var tabIndex: Int {
        switch self {
        case .all:
            return 0
        case .quote:
            return 1
        case .strategy:
            return 2
        case .news:
            return 3
        case .community:
            return 4
        case .help:
            return 5
        }
    }

    var title: String {
        switch self {
        case .all:
            return YXLanguageUtility.kLang(key: "search_all")
        case .quote:
            return YXLanguageUtility.kLang(key: "search_quotes")
        case .strategy:
            return YXLanguageUtility.kLang(key: "search_strategy")
        case .news:
            return YXLanguageUtility.kLang(key: "search_news")
        case .community:
            return YXLanguageUtility.kLang(key: "search_community")
        case .help:
            return YXLanguageUtility.kLang(key: "search_help")
        }
    }

    var requestParams: [Int] {
        switch self {
        case .all:
            return [YXSearchTypeParam.quote.rawValue,
                    YXSearchTypeParam.strategy.rawValue,
                    YXSearchTypeParam.news.rawValue,
                    YXSearchTypeParam.beerichMaster.rawValue,
                    YXSearchTypeParam.beerichCourse.rawValue,
                    YXSearchTypeParam.post.rawValue,
                    YXSearchTypeParam.help.rawValue]
        case .quote:
            return [YXSearchTypeParam.quote.rawValue]
        case .strategy:
            return [YXSearchTypeParam.strategy.rawValue]
        case .news:
            return [YXSearchTypeParam.news.rawValue]
        case .community(let subType):
            return subType.requestParams
        case .help:
            return [YXSearchTypeParam.help.rawValue]
        }
    }
}

extension SearchType: CaseIterable {

    static var allCases: [SearchType] = [
        .all,
        .quote,
        .strategy,
        .news,
        .community(.all),
        .help
    ]

    var subTypes: [SearchTypeBase] {
        switch self {
        case .community:
            return SearchCommunityType.allCases
        default:
            return []
        }
    }

}

enum SearchCommunityType: Int, CaseIterable, SearchTypeBase {
    case all
    case expert // 大咖
    case course   // 直播
    case post   // 帖子

    var title: String {
        switch self {
        case .all:
            return YXLanguageUtility.kLang(key: "common_all")
        case .expert:
            return YXLanguageUtility.kLang(key: "nbb_tab_master")
        case .course:
            return YXLanguageUtility.kLang(key: "nbb_course")
        case .post:
            return YXLanguageUtility.kLang(key: "search_post")
        }
    }

    var requestParams: [Int] {
        switch self {
        case .all:
            return [YXSearchTypeParam.beerichMaster.rawValue,
                    YXSearchTypeParam.beerichCourse.rawValue,
                    YXSearchTypeParam.post.rawValue]
        case .expert:
            return [YXSearchTypeParam.beerichMaster.rawValue]
        case .course:
            return [YXSearchTypeParam.beerichCourse.rawValue]
        case .post:
            return [YXSearchTypeParam.post.rawValue]
        }
    }
}

class SearchResultViewModel: YXViewModel {

}
