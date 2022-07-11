//
//  SearchViewController.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/2/28.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: YXViewController {

    private lazy var searchBar: SearchBarView = {
        let tf = SearchBarView()
        tf.textField.placeholder = YXLanguageUtility.kLang(key: "search_tip")
        tf.textField.delegate = self
        tf.textField.maximumTextLength = 50
        return tf
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = QMUITheme().foregroundColor()

        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.edges.equalToSuperview()
        }

        return view
    }()

    private lazy var contentView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.distribution = .fill

        addChild(historyVC)
        view.addArrangedSubview(historyVC.view)

        addChild(recommendVC)
        view.addArrangedSubview(recommendVC.view)

        return view
    }()

    private lazy var historyVC: SearchHistoryViewController = {
        let vm = SearchHistoryViewModel(services: self.viewModel.services, params: nil)
        let vc = SearchHistoryViewController(viewModel: vm)
        vc.didSelectKeyword = { [weak self] keyword in
            self?.searchBar.textField.text = keyword
            SearchHistoryManager.sharedManager.append(keyword)
            self?.historyVC.reloadData()
        }
        return vc
    }()

    private lazy var recommendVC: SearchRecommendViewController = {
        let vm = SearchRecommendViewModel(services: self.viewModel.services, params: nil)
        let vc = SearchRecommendViewController(viewModel: vm)
        return vc
    }()

    private lazy var resultVC: SearchResultViewController = {
        let vm = SearchResultViewModel(services: self.viewModel.services, params: nil)
        let vc = SearchResultViewController(viewModel: vm)
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func initSubviews() {
        super.initSubviews()

        navigationItem.hidesBackButton = true

        navigationItem.titleView = searchBar
        searchBar.snp.makeConstraints { make in
            make.height.equalTo(32)
        }

        _ = searchBar.cancelBtn.rx.tap.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else {
                return
            }
            self.searchBar.textField.resignFirstResponder()
            if self.qmui_isPresented() {
                self.viewModel.services.dismissViewModel(animated: true, completion: nil)
            } else {
                self.viewModel.services.popViewModel(animated: true)
            }
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.searchBar.textField.becomeFirstResponder()
        }

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(YXConstant.navBarHeight())
            }
            make.left.right.bottom.equalToSuperview()
        }

        addChild(resultVC)
        view.addSubview(resultVC.view)
        resultVC.view.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(YXConstant.navBarHeight())
            }
            make.left.right.bottom.equalToSuperview()
        }
    }

    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? SearchViewModel else { return }

        let keywordTrigger = searchBar.textField.rx.text.map { $0 ?? ""}.asDriver(onErrorJustReturn: "")
        let input = SearchViewModel.Input(keywordTrigger: keywordTrigger)

        let output = viewModel.transform(input: input)

        output.hideSearchResultView.drive(resultVC.view.rx.isHidden).disposed(by: rx.disposeBag)

        viewModel.keyword
            .throttle(RxTimeInterval.milliseconds(500), latest: true, scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] keyword in
                guard let `self` = self else { return }
                self.resultVC.searchWord = keyword
            }).disposed(by: rx.disposeBag)
    }

}

extension SearchViewController: QMUITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        SearchHistoryManager.sharedManager.append(textField.text)
        self.historyVC.reloadData()
        return true
    }

    func textField(_ textField: QMUITextField!, didPreventTextChangeIn range: NSRange, replacementString: String!) {
        QMUITips.show(withText: YXLanguageUtility.kLang(key: "up_to_50_characters"))
    }

}
