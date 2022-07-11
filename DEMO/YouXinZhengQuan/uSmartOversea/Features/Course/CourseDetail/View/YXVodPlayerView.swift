//
//  YXVodPlayerView.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//
import SDWebImage
import UIKit
import TXLiteAVSDK_Professional
import QMUIKit
import SnapKit
import RxSwift
import RxCocoa
import Alamofire
import YXKit

protocol YXVodPlayerViewDelegate: AnyObject {
    func onPlayEvent(_ player: YXVodPlayerView!, event EvtID: Int32, withParam param: [AnyHashable : Any]!)
}

class YXVodPlayerView: UIView, TXVodPlayListener {
    
    lazy var playBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage(named: "player_play_icon"), for: .selected)
        btn.setImage(UIImage(named: "parse_icon"), for: .normal)
        return btn;
    }()
    
    lazy var rateBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key:"nbb_speed"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            if self.isFullScreen && !self.isPortrait {
                self.addLandspaceRateView()
            } else {
                self.popMenu.showWith(animated: true)
            }
            
        }
        return btn;
    }()
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var rotateBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage(named: "rotate_icon"), for: .normal)
        btn.setImage(UIImage(named: "rotate_landspace_icon"), for: .selected)
        btn.qmui_tapBlock = { [weak self] _ in
            self?.transformVideo()
        }
        return btn;
    }()
    
    lazy var popMenu: QMUIPopupMenuView = {
       let menu = QMUIPopupMenuView()
        menu.automaticallyHidesWhenUserTap = true
        menu.cornerRadius = 2
        menu.itemHeight = 30
        menu.itemSeparatorColor = .clear
        menu.itemTitleFont = .systemFont(ofSize: 12)
        menu.itemTitleColor = .white
        menu.backgroundColor = .black.withAlphaComponent(0.5)
        menu.borderWidth = 0
        menu.arrowSize = .zero
        
        let rateItems = [2,1.5,1,0.5]
        let buttonItems = rateItems.compactMap { rate in
            return QMUIPopupMenuButtonItem.init(image: nil, title: "\(rate)X") { [weak self] aItem in
                self?.setRate(rate: (Float(rate)))
                menu.hideWith(animated: true)
            }
        }
        menu.items = buttonItems
        menu.sourceView = self.rateBtn
        return menu
    }()
    
    lazy var slider: UISlider = {
        let s = UISlider()
        s.qmui_thumbSize = CGSize(width: 8, height: 8)
        s.qmui_thumbColor = .white
        s.qmui_trackHeight = 4
        s.isContinuous = true
        s.minimumTrackTintColor = QMUITheme().mainThemeColor()
        s.maximumTrackTintColor = .white
        _ = s.rx.value.takeUntil(self.rx.deallocated).asObservable().subscribe(onNext: { [weak self] value in
            guard let `self` = self else { return }
            self.player.seek(self.duration*value)
        })
        return s
    }()
    
    lazy var player: TXVodPlayer = {
        let player = TXVodPlayer()
        player.vodDelegate = self
        player.loop = true
        player.setRenderMode(.RENDER_MODE_FILL_EDGE)
        player.isAutoPlay = true
        return player
    }()
    
    lazy var progressLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.3
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.qmui_color(withHexString: "#FFFFFF")
        return label;
    }()
    
    lazy var durationLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.3
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.qmui_color(withHexString: "#FFFFFF")
        return label;
    }()
    
    lazy var landspaceRateView: LandspaceRateView = {
        let view = LandspaceRateView()
        view.didSelectCallBack = { [weak self] value in
            self?.removeLandspaceRateView()
            self?.setRate(rate: value)
        }
        return view
    }()
    
    lazy var backBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage(named: "nav_back_white"), for: .normal)
        btn.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            if self.isFullScreen {
                self.transformVideo()
            } else {
                self.backBtnTapCallback?()
            }
        }
        return btn;
    }()
    
    lazy var moreBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage(named: "share_icon"), for: .normal)
        return btn;
    }()
    
    lazy var topView: UIView = {
        let view = UIView()
        let bg = UIImageView()
        bg.image = UIImage(named:"player_top_bg")
        bg.contentMode = .scaleToFill
        view.addSubview(bg)
        view.addSubview(backBtn)
        view.addSubview(moreBtn)
        bg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        moreBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(24)
        }
        backBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(24)
        }
        return view
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        
        let bg = UIImageView()
        bg.image = UIImage(named:"player_bottom_bg")
        bg.contentMode = .scaleToFill
        view.addSubview(bg)
       // view.addSubview(playBtn)
        view.addSubview(progressLabel)
        view.addSubview(slider)
        view.addSubview(durationLabel)
        view.addSubview(rateBtn)
        view.addSubview(rotateBtn)
        
        bg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
//        playBtn.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(12)
//            make.centerY.equalToSuperview()
//            make.width.height.equalTo(24)
//        }
        
        progressLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.width.equalTo(30)
        }
        
        slider.snp.makeConstraints { make in
            make.left.equalTo(progressLabel.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.equalTo(durationLabel.snp.left).offset(-4)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.right.equalTo(rateBtn.snp.left).offset(-8)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.width.equalTo(30)
        }
        
        rateBtn.snp.makeConstraints { make in
            make.right.equalTo(rotateBtn.snp.left).offset(-8)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }
        
        rotateBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var lessonNameLable : UILabel = {
       let lab = UILabel()
        lab.font = .systemFont(ofSize: 14)
        lab.textColor = .white
        lab.isHidden = true
        return lab
    }()
    
    var duration: Float = 0
    var progress: Float = 0
    var isPortrait: Bool = false
    var isFullScreen: Bool = false
    var isPlaying: Bool {
        return player.isPlaying()
    }
    
    /// 屏幕旋转回调
    var rotateCallback: ((Bool,Bool) -> Void)?
    
    /// 点击返回回调
    var backBtnTapCallback: (() -> Void)?
    
    weak var delegate: YXVodPlayerViewDelegate?
    
    private(set) var seek: Double = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindingAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupUI() {
        backgroundColor = .black
        player.setupVideoWidget(self, insert: 0)
        addSubview(bottomView)
        addSubview(topView)
        addSubview(coverImageView)
        addSubview(playBtn)
        addSubview(lessonNameLable)
        coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        topView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(44)
        }
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(43)
        }
        
        playBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 50, height: 50))
        }
        
        lessonNameLable.snp.makeConstraints { make in
            make.left.equalTo(backBtn.snp.right).offset(8)
            make.right.equalTo(playBtn.snp.centerX)
            make.centerY.equalTo(backBtn.snp.centerY)
        }
        
    }
    
    func bindingAction() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapClick))
        addGestureRecognizer(tap)
        
        hiddenState()
        
        _ = playBtn.rx.tap.takeUntil(rx.deallocated).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            if self.player.isPlaying() {
                self.playBtn.isSelected = true
                self.player.pause()
            } else {
                self.playBtn.isSelected = false
                self.player.resume()
            }
        })
        
//        let _ = NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification).takeUntil(self.rx.deallocated).subscribe { [weak self] _ in
//            guard let `self` = self else { return }
//            if self.player.isPlaying() {
//                UIApplication.shared.beginReceivingRemoteControlEvents()
//
//            }
//        }
    }
    

    
    func transformVideo() {
        isFullScreen = !isFullScreen
        self.rotateCallback?(isFullScreen,isPortrait)
        if !isPortrait {
            if isFullScreen {
                rotateBtn.isSelected = true
                YXToolUtility.forceToLandscapeRightOrientation()
            } else {
                rotateBtn.isSelected = false
                YXToolUtility.forceToPortraitOrientation()
            }
        }
        
        topView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(44 + (isFullScreen ? YXConstant.statusBarHeight() : 0))
        }
        
        bottomView.snp.remakeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(isFullScreen ? 63 :43)
        }
        lessonNameLable.isHidden = false
        if !isPortrait {

//            playBtn.snp.remakeConstraints { make in
//                make.left.equalToSuperview().offset(isFullScreen ? 70 : 12)
//                make.centerY.equalToSuperview()
//                make.width.height.equalTo(24)
//            }

            moreBtn.snp.remakeConstraints { make in
                make.right.equalToSuperview().offset(isFullScreen ? -87 : -12)
                make.top.equalToSuperview().offset(12)
                make.width.height.equalTo(24)
            }
            backBtn.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(isFullScreen ? 87 : 12)
                make.top.equalToSuperview().offset(12)
                make.width.height.equalTo(24)
            }
            rotateBtn.snp.remakeConstraints { make in
                make.right.equalToSuperview().offset(isFullScreen ? -87 : -12)
                make.height.width.equalTo(24)
                make.centerY.equalToSuperview()
            }
            progressLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(isFullScreen ? 87 : 12)
                make.height.equalTo(24)
                make.centerY.equalToSuperview()
                make.width.equalTo(30)
            }
            
            lessonNameLable.isHidden = true
        }

    }
    
    func play(url: String, duration: Float, coverImageUrl: String? = nil) {
        if let url = URL(string: coverImageUrl ?? "") {
            coverImageView.isHidden = false
            coverImageView.sd_setImage(with: url)
        }
        self.duration = 0
        self.progress = 0
        player.setStartTime(CGFloat(duration))
        player.startPlay(url)
    }
    
    func stop() {
        player.stopPlay()
        player.removeVideoWidget()
    }
    
    func pause() {
        player.pause()
        playBtn.isSelected = true
    }
    
    func resume() {
        player.resume()
        playBtn.isSelected = false
    }
    
    func setRate(rate: Float) {
        self.player.setRate(rate)
        self.rateBtn.setTitle("\(rate)X", for: .normal)
    }
    
    @objc func tapClick(){
        if (landspaceRateView.superview != nil) {
            self.removeLandspaceRateView()
        }
        if (bottomView.isHidden) {
            UIView.animate(withDuration: 0.3) { [self] in
                NSObject.cancelPreviousPerformRequests(withTarget: self)
                self.bottomView.isHidden = false
                self.playBtn.isHidden = false
                self.topView.isHidden = false
                if isFullScreen{
                    self.lessonNameLable.isHidden = false
                }
               
                self.perform(#selector(hiddenState), afterDelay: 3)
            }
        }
    }
    
    @objc func hiddenState() {
        self.bottomView.isHidden = true
        self.playBtn.isHidden = true
        self.topView.isHidden = true
        if isFullScreen{
            self.lessonNameLable.isHidden = true
        }
    }
    
    func onPlayEvent(_ player: TXVodPlayer!, event EvtID: Int32, withParam param: [AnyHashable : Any]!) {
        self.delegate?.onPlayEvent(self, event: EvtID, withParam: param)
        switch EvtID {
        case PLAY_EVT_PLAY_BEGIN.rawValue:
            coverImageView.isHidden = true
            self.playBtn.isSelected = false
            break
        case PLAY_EVT_CHANGE_RESOLUTION.rawValue:
            
            if let width = param[EVT_PARAM1] as? Float, let height = param[EVT_PARAM2] as? Float {
                ///默认横屏
                isPortrait = false
            }
            break
        case PLAY_EVT_PLAY_PROGRESS.rawValue:
            if let duration = param[EVT_PLAY_DURATION] as? Float, let progress = param[EVT_PLAY_PROGRESS] as? Float  {
                self.duration = duration
                self.progress = progress
                self.slider.value = progress/duration
                self.progressLabel.text = String(format: "%02d:%02d", Int(ceil(progress)/60),Int(ceil(progress))%60)
                self.durationLabel.text = String(format: "%02d:%02d", Int(ceil(duration)/60),Int(ceil(duration))%60)
            }
            break
        case PLAY_EVT_PLAY_LOADING.rawValue:
            break
        case PLAY_EVT_VOD_PLAY_PREPARED.rawValue:
            break
        case PLAY_EVT_VOD_LOADING_END.rawValue:
            break
        default:
            break
        }
    }
    
    func onNetStatus(_ player: TXVodPlayer!, withParam param: [AnyHashable : Any]!) {
        
    }
        
    func addLandspaceRateView() {
        addSubview(landspaceRateView)
        landspaceRateView.frame = CGRect(x: YXConstant.screenWidth*2, y: 0, width: 320, height: YXConstant.screenWidth)
        UIView.animate(withDuration: 0.5) {
            self.landspaceRateView.frame = CGRect(x: YXConstant.screenWidth*2 - 320 + YXConstant.safeAreaInsetsBottomHeight(), y: 0, width: 320, height: YXConstant.screenWidth)
        }
    }
    
    func removeLandspaceRateView() {
        UIView.animate(withDuration: 0.5) {
            self.landspaceRateView.frame = CGRect(x: YXConstant.screenWidth*2, y: 0, width: 320, height: YXConstant.screenWidth)
        } completion: { _ in
            self.landspaceRateView.removeFromSuperview()
        }
    }
}

///全屏时播放速度选择器
class LandspaceRateView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    let rateList = [2.0,1.5,1.25,1,0.75,0.5]
    
    var didSelectCallBack: ((Float)->Void)?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LandspaceRateCell.self, forCellReuseIdentifier: NSStringFromClass(LandspaceRateCell.self))
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: 0, width: YXConstant.screenHeight/2, height: YXConstant.screenWidth)
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 0.94)
        layer.colors = [UIColor.black.withAlphaComponent(0).cgColor,UIColor.black.withAlphaComponent(0.5).cgColor]
        layer.locations = [0,1]
        self.layer.insertSublayer(layer, at: 0)
        backgroundColor = .clear
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rateList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return YXConstant.screenWidth/CGFloat(rateList.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LandspaceRateCell.self), for: indexPath) as! LandspaceRateCell
        let rate = rateList[indexPath.row]
        cell.btn.setTitle("\(rate)X", for: .normal)
        cell.btn.qmui_tapBlock = { [weak self] _ in
            self?.didSelectCallBack?(Float(rate))
        }
        return cell
    }
    
}

class LandspaceRateCell : UITableViewCell {
    
    lazy var btn: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(btn)
//        contentView.backgroundColor = .clear
        backgroundColor = .clear
        btn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
