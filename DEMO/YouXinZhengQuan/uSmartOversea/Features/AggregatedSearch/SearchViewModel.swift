//
//  SearchViewModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/2/28.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class SearchViewModel: YXViewModel {

    struct Input {
        let keywordTrigger: Driver<String>
    }

    struct Output {
        let hideSearchResultView: Driver<Bool>
    }

    let keyword = BehaviorRelay(value: "")

    func transform(input: Input) -> Output {
        input.keywordTrigger.distinctUntilChanged().asObservable()
            .bind(to: keyword).disposed(by: rx.disposeBag)

        let hideSearchResultView = keyword.asObservable().map { $0.isEmpty }.asDriver(onErrorJustReturn: false)

        return Output(hideSearchResultView: hideSearchResultView)
    }
    
}
