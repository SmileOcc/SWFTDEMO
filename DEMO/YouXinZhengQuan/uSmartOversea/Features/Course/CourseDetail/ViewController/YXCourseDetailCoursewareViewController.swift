//
//  YXCourseDetailCoursewareViewController.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit
import RxSwift
import RxCocoa
import SDWebImage
import YXKit

class YXCourseDetailCoursewareViewController: YXHKTableViewController {
    
    var vm: YXCoursewareViewModel!
    
    var heightCache: [CGFloat] = []
    
    let pageLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = QMUITheme().mainThemeColor()
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 4
        label.backgroundColor = UIColor.qmui_color(withHexString: "#ECEDFF")
        return label
    }()
    
    var dataSource: [String] = [] {
        didSet {
            self.heightCache = self.dataSource.compactMap{ _ in return UITableView.automaticDimension}
            self.tableView.reloadData()
            self.pageLabel.isHidden = dataSource.isEmpty
            self.pageLabel.text = "1/\(self.dataSource.count)"
        }
    }
    
    let emptyButtonAction = PublishSubject<()>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didInitialize(){
        super.didInitialize()
        inputViewModel()
    }
    
    func inputViewModel() {
        let viewWillAppear = self.rx.methodInvoked(#selector(viewWillAppear)).map { e in
            return ()
        }.asDriver(onErrorJustReturn: ())
        vm = YXCoursewareViewModel(input: (viewWillAppear: viewWillAppear,
                                           refreshAction: emptyButtonAction.asDriver(onErrorJustReturn: ())))
    }
    
    func setupUI() {
        self.view.backgroundColor = QMUITheme().foregroundColor()

        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(YXCoursewareCell.self, forCellReuseIdentifier: NSStringFromClass(YXCoursewareCell.self))
        view.addSubview(pageLabel)
        pageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(12)
            make.width.equalTo(46)
            make.height.equalTo(22)
        }
        
    }
        
    func binding() {
        
        vm.activity.drive(loadingHud.rx.isShowNetWorkLoading).disposed(by: disposeBag)
        
        vm.videoId.subscribe(onNext:{ [weak self] id in
            guard let `self` = self else { return }
            self.dataSource = []
        }).disposed(by: disposeBag)
        
        vm.courseWareResult.drive{ [weak self] res in
            guard let `self` = self else { return }
            self.dataSource = res ?? []
            if let res = res {
                if res.isEmpty {
                    self.dataSource = []
                   // self.showEmpty(emptyType: .noCourseware)
                    self.showNoDataEmptyView()
                    self.emptyView?.textLabel.text = YXLanguageUtility.kLang(key: "nbb_nocourseware")
                } else {
                    self.hideEmptyView()
                    self.dataSource = res
                }
            } else {
                self.showErrorEmptyView()
            }
        }.disposed(by: disposeBag)
        
    }
    
    override func emptyRefreshButtonAction() {
        self.hideEmptyView()
        emptyButtonAction.onNext(())
    }
    
}

extension YXCourseDetailCoursewareViewController {
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXCoursewareCell.self), for: indexPath) as! YXCoursewareCell
        if let url = URL(string: self.dataSource[indexPath.row]) {
            cell.selectionStyle = .none
            cell.lessonImage.sd_setImage(with: url, placeholderImage: UIImage(named: "banner_placeholder"), options: []) { [weak self] image, error, cacheType, url in
                if let image = image {
                    self?.heightCache[indexPath.row] = (image.size.height / image.size.width)*(YXConstant.screenWidth-32)
                }
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightCache[indexPath.row]
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let index = tableView.indexPathForRow(at: scrollView.contentOffset)?.row {
            self.pageLabel.text = "\(index+1)/\(dataSource.count)"
        }
    }
    
}
