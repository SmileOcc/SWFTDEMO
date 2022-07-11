//
//  YXShareLotteryViewController.swift
//  uSmartOversea
//
//  Created by Evan on 2022/1/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import FLAnimatedImage

enum YXShareLotteryStatus {
    case waiting    // 等待开奖
    case win        // 中奖
    case lose       // 未中奖
}

class YXShareLotteryViewController: UIViewController {

    var orderId: String?

    private var isRequesting = false
    private var status: YXShareLotteryStatus = .waiting

    private var textColorLevel1 = UIColor.qmui_color(withHexString: "#2A2A34")!
    private var textColorLevel3 = UIColor.qmui_color(withHexString: "#888996")!

    private lazy var lotteryView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var lotteryBgView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "share_lottery_bg")
        return view
    }()

    private lazy var lightImageView: UIImageView = {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.repeatCount = MAXFLOAT
        rotationAnimation.duration = 5
        rotationAnimation.isRemovedOnCompletion = false

        let view = UIImageView()
        view.image = UIImage(named: "img_light")
        view.contentMode = .scaleAspectFill
        view.layer.add(rotationAnimation, forKey: nil)

        return view
    }()

    private lazy var starImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "img_star")
        return view
    }()

    private lazy var boxImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "img_box")
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer.init(target: self, action: #selector(startLottery))
        view.addGestureRecognizer(tap)

        let centerY = 64 + 152 / 2

        let animation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue = centerY - 10
        animation.toValue = centerY + 10
        animation.repeatCount = MAXFLOAT
        animation.duration = 1
        animation.isRemovedOnCompletion = false
        animation.autoreverses = true
        view.layer.add(animation, forKey: nil)

        return view
    }()

    private lazy var waitingView: UIView = {
        let view = UIView()

        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "get_mystery_box_tip_title")
        titleLabel.numberOfLines = 0
        titleLabel.textColor = textColorLevel1
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.lineBreakMode = .byCharWrapping
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
        }

        let tipsLabel = UILabel()
        tipsLabel.numberOfLines = 0
        tipsLabel.text = YXLanguageUtility.kLang(key: "get_mystery_box_tip_content")
        tipsLabel.textColor = textColorLevel3
        tipsLabel.font = .systemFont(ofSize: 12, weight: .regular)
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }

        return view
    }()

    private lazy var winView: UIView = {
        let view = UIView()

        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "win_prize_title")
        titleLabel.textAlignment = .center
        titleLabel.textColor = textColorLevel1
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.right.equalToSuperview().inset(16)
        }

        view.addSubview(self.prizeLabel)
        prizeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }
        let tipsLabel = UILabel()
        tipsLabel.numberOfLines = 0
        tipsLabel.text = YXLanguageUtility.kLang(key: "win_prize_content")
        tipsLabel.textColor = textColorLevel3
        tipsLabel.font = .systemFont(ofSize: 12, weight: .regular)
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(prizeLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }

        return view
    }()

    private lazy var loseView: UIView = {
        let view = UIView()

        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "lose_prize_title")
        titleLabel.textAlignment = .center
        titleLabel.textColor = textColorLevel1
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(21)
            make.left.right.equalToSuperview().inset(16)
        }

        let tipsLabel = UILabel()
        tipsLabel.textAlignment = .center
        tipsLabel.text = YXLanguageUtility.kLang(key: "lose_prize_content")
        tipsLabel.textColor = QMUITheme().themeTextColor()
        tipsLabel.font = .systemFont(ofSize: 20, weight: .medium)
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-62)
        }

        return view
    }()

    private lazy var prizeImageContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.layer.cornerRadius = 62
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.qmui_color(withHexString: "#EAEAEA")?.cgColor
        view.layer.borderWidth = 1.0

        view.addSubview(prizeImageView)
        prizeImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }

        view.addSubview(star2ImageView)
        star2ImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        return view
    }()

    private lazy var prizeImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var star2ImageView: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        view.image = UIImage(named: "img_star2")
        return view
    }()

    private lazy var prizeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = QMUITheme().themeTintColor()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()

    private lazy var fireworksImageView: FLAnimatedImageView = {
        let view = FLAnimatedImageView()
        view.isHidden = true
        view.contentMode = .scaleAspectFill
        view.loopCompletionBlock = { [weak view] loopCountRemaining in
            view?.isHidden = true
        }

        if let path = Bundle.main.path(forResource: "fireworks", ofType: "gif"),
           let data = try? Data.init(contentsOf: URL(fileURLWithPath: path)) {
            let image = FLAnimatedImage(animatedGIFData: data)
            view.animatedImage = image
        }

        return view
    }()

    private lazy var shakeImageView: FLAnimatedImageView = {
        let view = FLAnimatedImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 40
        view.layer.masksToBounds = true
        view.backgroundColor = .black.withAlphaComponent(0.1)

        if let path = Bundle.main.path(forResource: "shake", ofType: "gif"),
           let data = try? Data.init(contentsOf: URL(fileURLWithPath: path)) {
            let image = FLAnimatedImage(animatedGIFData: data)
            view.animatedImage = image
        }

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        UIApplication.shared.applicationSupportsShakeToEdit = true
        self.becomeFirstResponder()

        initSubviews()
    }

    private func initSubviews() {
        view.addSubview(lotteryView)
        lotteryView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-64)
            make.centerX.equalToSuperview()
            make.width.equalTo(285)
//            make.height.equalTo(321)
        }

        lotteryView.addSubview(lotteryBgView)
        lotteryBgView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(182)
        }

        let logoImageView = UIImageView()
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: "hold_share_logo")
        lotteryView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16)
            make.width.equalTo(75)
            make.height.equalTo(15)
        }

        lotteryView.addSubview(lightImageView)
        lotteryView.addSubview(starImageView)
        lotteryView.addSubview(boxImageView)

        lightImageView.snp.makeConstraints { make in
            make.center.equalTo(boxImageView.snp.center)
            make.width.equalTo(285)
            make.height.equalTo(285)
        }

        starImageView.snp.makeConstraints { make in
            make.top.equalTo(boxImageView.snp.top)
            make.centerX.equalTo(boxImageView.snp.centerX)
        }

        lotteryView.addSubview(waitingView)
        waitingView.snp.makeConstraints { make in
            make.top.equalTo(lotteryBgView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        lotteryView.addSubview(prizeImageContainerView)
        prizeImageContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(lotteryBgView.snp.bottom)
            make.width.height.equalTo(124)
        }

        boxImageView.snp.makeConstraints { make in
            make.top.equalTo(64)
            make.centerX.equalToSuperview()
            make.width.equalTo(165)
            make.height.equalTo(152)
        }

        lotteryView.addSubview(fireworksImageView)

        fireworksImageView.snp.makeConstraints { make in
            make.center.equalTo(boxImageView.snp.center)
            make.width.equalTo(285)
            make.height.equalTo(285)
        }

        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "pop_close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)

        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(lotteryView.snp.bottom).offset(32)
            make.width.height.equalTo(32)
            make.centerX.equalToSuperview()
        }

        view.addSubview(shakeImageView)
        shakeImageView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(55)
            make.centerX.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
    }

    @objc private func startLottery() {
        guard let orderId = self.orderId else {
            return
        }

        if isRequesting {
            return
        }

        isRequesting = true

        let requestModel = YXDrawBindBoxRequestModel()
        requestModel.orderId = orderId

        let request = YXRequest(request: requestModel)
        request.startWithBlock { [weak self] responseModel in
            guard let `self` = self else { return }

            self.isRequesting = false

            if responseModel.code == .success,
               let model = responseModel as? YXSharePrizeModel {
                self.openPrize(model)
            } else {
                QMUITips.show(withText: responseModel.msg, in: self.lotteryView)
            }
        } failure: { [weak self] _ in
            self?.isRequesting = false
        }
    }

    private func openPrize(_ prize: YXSharePrizeModel) {
        if prize.isWin {
            status = .win
        } else {
            status = .lose
        }

        waitingView.removeFromSuperview()

        if status == .win {
            lotteryView.addSubview(winView)
            winView.snp.makeConstraints { make in
                make.top.equalTo(lotteryBgView.snp.bottom)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        } else if status == .lose {
            lotteryView.addSubview(loseView)
            loseView.snp.makeConstraints { make in
                make.top.equalTo(lotteryBgView.snp.bottom)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }

        lightImageView.isHidden = status == .lose

        starImageView.isHidden = true
        boxImageView.isHidden = true

        prizeImageContainerView.isHidden = false
        if status == .win {
            prizeImageView.sd_setImage(with: URL(string: prize.picUrl))
            star2ImageView.isHidden = false
        } else if status == .lose {
            prizeImageView.image = UIImage(named: "img_lose_prize")
            star2ImageView.isHidden = true
        }

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0
        scaleAnimation.toValue = 1
        scaleAnimation.repeatCount = 1
        scaleAnimation.duration = 0.3
        scaleAnimation.isRemovedOnCompletion = true
        prizeImageView.layer.add(scaleAnimation, forKey: nil)

        fireworksImageView.isHidden = status != .win

        prizeLabel.text = prize.displayName

        shakeImageView.isHidden = true

        if status == .win {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred()
        }
    }

    @objc func closeButtonAction() {
        UIApplication.shared.applicationSupportsShakeToEdit = false
        self.dismiss(animated: false, completion: nil)
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)

        if status != .waiting || isRequesting {
            return
        }

        startLottery()
    }
}
