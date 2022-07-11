//
//  SearchResultListViewModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/2/28.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchResultListViewModel: YXTableViewModel {

    var searchWord: String = ""

    var searchType: SearchType = .all {
        didSet {
            switch searchType {
            case .all:
                shouldInfiniteScrolling = false
                pageSize = 4
            case .community(let subType):
                shouldInfiniteScrolling = subType != .all
                pageSize = subType == .all ? 4 : 20
            default:
                shouldInfiniteScrolling = true
                pageSize = 20
            }

            self.perPage = pageSize
        }
    }

    var pageSize: UInt = 20
    var sectionSearchTypes: [SearchType] = []

    private(set) var searchRequest: YXRequest?
    // TODO: 用于提前取消网络请求，可能不是正确的处理方式
    private(set) var searchSubscriber: RACSubscriber?

    override func initialize() {
        super.initialize()

        shouldPullToRefresh = true

        if let type = params?["type"] as? SearchType {
            searchType = type
        } else {
            searchType = .all
        }
    }

    deinit {
        cancelRequest()
    }

    override func request(withOffset offset: Int) -> RACSignal<AnyObject>! {
        return RACSignal.createSignal { [weak self] subscriber -> RACDisposable? in
            guard let `self` = self, !self.searchWord.isEmpty else {
                self?.constructListData(with: nil)

                subscriber.sendNext(nil)
                subscriber.sendCompleted()

                self?.searchRequest = nil
                self?.searchSubscriber = nil

                return nil
            }

            self.searchRequest?.stop()
            self.searchRequest = nil

            let requestModel = SearchRequestAPI()
            requestModel.q = self.searchWord
            requestModel.from = offset
            requestModel.size = self.perPage
            requestModel.searchTypes = self.searchType.requestParams

            let request = YXRequest(request: requestModel)
            request.startWithBlock { [weak self] responseModel in
                guard let `self` = self else { return }

                self.constructListData(with: responseModel)

                subscriber.sendNext(nil)
                subscriber.sendCompleted()

                self.searchRequest = nil
                self.searchSubscriber = nil
            } failure: { [weak self] request in
                guard let `self` = self else { return }

                self.sectionSearchTypes = []
                self.dataSource = nil

                subscriber.sendNext(nil)
                subscriber.sendCompleted()

                self.searchRequest = nil
                self.searchSubscriber = nil
            }

            self.searchRequest = request
            self.searchSubscriber = subscriber

            return nil
        }
    }

    func cancelRequest() {
        self.searchRequest?.stop()
        self.searchRequest = nil

        self.searchSubscriber?.sendNext(nil)
        self.searchSubscriber?.sendCompleted()
        self.searchSubscriber = nil
    }

    /// 构造列表数据
    /// - Parameter searchResult: 搜索结果
    private func constructListData(with responseModel: YXResponseModel?) {
        guard let searchResult = responseModel as? SearchResultModel else {
            self.sectionSearchTypes = []
            self.dataSource = []
            return
        }

        var tmpSectionSearchTypes: [SearchType] = []
        var tmpDataSource: [[Any]] = []

        if !searchResult.secuList.isEmpty {
            tmpSectionSearchTypes.append(.quote)

            let list = searchResult.secuList.map { SearchQuoteCellViewModel(model: $0, searchWord: self.searchWord) }
            tmpDataSource.append(list)
        }

        if !searchResult.beeRichMasterList.isEmpty {
            tmpSectionSearchTypes.append(.community(.expert))

            let list = searchResult.beeRichMasterList.map { SearchBeeRichMasterCellViewModel(model: $0, searchWord: self.searchWord) }
            tmpDataSource.append(list)
        }

        if !searchResult.strategyList.isEmpty {
            tmpSectionSearchTypes.append(.strategy)

            let list = searchResult.strategyList.map { SearchStrategyCellViewModel(model: $0, searchWord: self.searchWord) }
            tmpDataSource.append(list)
        }

        if !searchResult.newsList.isEmpty {
            tmpSectionSearchTypes.append(.news)

            let list = searchResult.newsList.map { SearchNewsCellViewModel(model: $0, searchWord: self.searchWord) }
            tmpDataSource.append(list)
        }

        if !searchResult.beeRichCourseList.isEmpty {
            tmpSectionSearchTypes.append(.community(.course))

            let list = searchResult.beeRichCourseList.map { SearchBeeRichCourseCellViewModel(model: $0, searchWord: self.searchWord) }
            tmpDataSource.append(list)
        }

        if !searchResult.postList.isEmpty {
            tmpSectionSearchTypes.append(.community(.post))

            let list = searchResult.postList.map { SearchPostCellViewModel(model: $0, searchWord: self.searchWord) }
            tmpDataSource.append(list)
        }

        if !searchResult.helpList.isEmpty {
            tmpSectionSearchTypes.append(.help)

            let list = searchResult.helpList.map { SearchHelpCellViewModel(model: $0, searchWord: self.searchWord) }
            tmpDataSource.append(list)
        }

        if self.page <= 1 {
            self.sectionSearchTypes = tmpSectionSearchTypes
            self.dataSource = tmpDataSource
        } else {
            // 只有单类型的搜索才有分页，所以直接取 first 元素了
            if let oldData = dataSource.first,
               let newData = tmpDataSource.first {
                self.dataSource = [oldData + newData]
            }
        }

        if self.shouldInfiniteScrolling {
            if let data = tmpDataSource.first, data.count >= self.perPage {
                self.loadNoMore = false
            } else {
                self.loadNoMore = true
            }
        }
    }
}
