//
//  STLLottieView.swift
// XStarlinkProject
//
//  Created by odd on 2021/7/14.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import Lottie

@objcMembers class MyLottieView: UIView {
    let lottieView = AnimationView()
    
    init(frame:CGRect, name:String!) {
        super.init(frame: frame)
        
        lottieView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        self.addSubview(lottieView)

        lottieView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        lottieView.animation = Animation.named(name)//绑定Lottie动画(替换成你自己的 json 动画)

        lottieView.loopMode = .playOnce//动画效果 执行单次、多次

        lottieView.contentMode = .scaleAspectFit

        lottieView.backgroundBehavior = .pauseAndRestore//设置进入后台是否暂停动画
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func play(completion:@escaping LottieCompletionBlock) {
        lottieView.play(completion: completion);
    }
    func stop() {
        lottieView.stop();
    }

}
