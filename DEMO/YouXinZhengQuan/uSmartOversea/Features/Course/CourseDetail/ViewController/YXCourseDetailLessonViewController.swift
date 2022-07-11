//
//  YXCourseDetailLessonViewController.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import YXKit

class YXCourseDetailLessonViewController: YXHKTableViewController {
    
    var viewModel: YXCourseLessonViewModel!
    
    let collectAction = PublishSubject<YXCourseVideoResModel?>()
    
    var didSelectLessonCallback: ((YXCourseVideoResModel,Float) -> Void)?
    
    let emptyButtonAction = PublishSubject<()>()
    
    var dataSource: [YXCourseLessonResModel] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    lazy var lessonName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = QMUITheme().textColorLevel3()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var courseNameLb: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 8, weight: .regular)
        label.textColor = QMUITheme().themeTextColor()
        label.text = YXLanguageUtility.kLang(key: "news_course")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.cornerRadius = 2
        label.layer.borderWidth = 0.5
        label.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
        label.layer.borderColor = QMUITheme().themeTextColor().cgColor
        return label
    }()
    
    lazy var hearderView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.addSubview(courseNameLb)
        view.addSubview(lessonName)
        
        courseNameLb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(14)
//            make.width.equalTo(35)
            make.centerY.equalToSuperview()
        }
        
        lessonName.snp.makeConstraints { make in
            make.left.equalTo(courseNameLb.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        return view
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
        // Do any additional setup after loading the view.
    }
    
    override func didInitialize() {
        super.didInitialize()
        let viewDidLoad = self.rx.methodInvoked(#selector(viewDidLoad)).map { e in
            return ()
        }.asDriver(onErrorJustReturn: ())
        viewModel = YXCourseLessonViewModel(input: (viewDidLoad: viewDidLoad,
                                                    refreshAction: emptyButtonAction.asDriver(onErrorJustReturn: ())))
    }
    
    override func shouldHideTableHeaderViewInitial() -> Bool {
        return true
    }
    
    func setupUI() {
//        self.view.backgroundColor = QMUITheme().foregroundColor()

        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: YXConstant.safeAreaInsetsBottomHeight()+52, right: 0)
        tableView.estimatedSectionHeaderHeight = 50
        tableView.register(YXLessonCell.self, forCellReuseIdentifier: NSStringFromClass(YXLessonCell.self))
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        #if compiler(>=5.5)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        #endif
    }
    
    func binding() {
       // viewModel.activity.drive(loadingHud.rx.isShowNetWorkLoading).disposed(by: disposeBag)
        
        viewModel.lessonsResult.drive{ [weak self] res in
            self?.configLessons(model: res)
        }.disposed(by: disposeBag)
        
        viewModel.fetchCourseDetail().subscribe { [weak self] res in
            self?.lessonName.text = "--"
            if let coursename = res?.courseName,!coursename.isEmpty {
                self?.lessonName.text = coursename
            }
        } onError: { [weak self] err in
            
        }.disposed(by: disposeBag)
    }
    
    func configLessons(model :YXCourseLessonListResModel?) {
        if let model = model {
            ///有播放历史
            if let lessonList = model.lessonList {
                if let record = model.record , viewModel.isUserPayed {
                    for lesson in lessonList {
                        if record.lessonIdStr == lesson.lessonIdStr {
                            self.viewModel.selectedLesson.accept((lesson,record))
                        }
                    }
                } else {
                    self.viewModel.selectedLesson.accept((lessonList.first,nil))
                }
            }
            if let list = model.lessonList, !list.isEmpty {
                self.hideEmptyView()
                self.dataSource = list
            } else {
               // self.showEmpty(emptyType: .noArticle)
                self.dataSource = []
            }
        } else {
            showErrorEmptyView()
        }

    }
    
    override func emptyRefreshButtonAction() {
        self.hideEmptyView()
        emptyButtonAction.onNext(())
    }
    
}

extension YXCourseDetailLessonViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXLessonCell.self), for: indexPath) as! YXLessonCell
        let model = dataSource[indexPath.row]
        cell.selectionStyle = .none
        cell.isPlaying = model.videoList.first?.videoIdStr == self.viewModel.selectedLesson.value.0?.videoList.first?.videoIdStr
        if let videoModel = model.videoList.first {
            cell.titleLabel.text = model.lessonName
            cell.count.setTitle("\(videoModel.watchCount)", for: .normal)
            cell.duration.setTitle(String(format: "%02d:%02d", Int(ceil(Double(videoModel.videoDuration))/60),Int(ceil(Double(videoModel.videoDuration)))%60), for: .normal)
            
        }
        cell.isLocked = !self.viewModel.isUserPayed
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73;
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if viewModel.isUserPayed {
            ///lessonId不同,过滤重复点击
            if let lessonId = self.viewModel.selectedLesson.value.0?.lessonIdStr,lessonId != dataSource[indexPath.row].lessonIdStr {
                viewModel.selectedLesson.accept((dataSource[indexPath.row],nil))
                tableView.reloadData()
            }
        } else {
            if indexPath.row != 0 {
                YXCourseDetailViewController.showPurchase(courseId: self.viewModel.courseId,
                                                          callback: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return hearderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
