//
//  LanuchAdvView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVLanuchsAdvView.h"

@interface OSSVLanuchsAdvView() {
    NSTimer     *_timer;
    int         _time;
    OSSVAdvsEventsModel   *_EventModel;
}
@end

@implementation OSSVLanuchsAdvView

- (instancetype)initWithFrame:(CGRect)frame advModel:(OSSVAdvsEventsModel *)OSSVAdvsEventsModel image:(UIImage *)advImg{
    if (self = [super initWithFrame:frame]) {
        
        
        // 图片显示不拉伸
        CGFloat imgW = advImg.size.width;
        CGFloat imgH = advImg.size.height;
        
        CGFloat advSereenW = SCREEN_WIDTH;
        CGFloat advSereenH = SCREEN_HEIGHT;
        CGFloat changeW = advSereenW;
        CGFloat changeH = advSereenH;
        
        if (imgW > 0 && imgH > 0) {
            CGFloat scale = imgW / imgH;
            CGFloat screeneScale = advSereenW / advSereenH;
            
            //宽 大于 高
            if (scale > screeneScale) {
                changeW = imgW * changeH / imgH;
            } else {
                changeH = imgH * changeW / imgW;
            }
        }
        
        _EventModel = OSSVAdvsEventsModel;
        [WINDOW addSubview:self];

        self.advertImgView.image = advImg;

        [self addSubview:self.advertImgView];
        
        [self addSubview:self.btn];
        
        [self.btn addSubview:self.skipLab];
        [self.btn addSubview:self.timeLab];
 
    
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(advertImgViewDoAction)];
        [self.advertImgView addGestureRecognizer:tap];
        
        // 2
        _time = 2;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        
        // 图片居中
        if (changeW > 0 && changeH > 0) {
            [self.advertImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(changeW, changeH));
                make.center.mas_equalTo(self);
            }];
        } else {
            [self.advertImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self);
            }];
        }
        
        
        [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
            if (kIS_IPHONEX) {
                make.top.equalTo(@51);
            } else {
                make.top.equalTo(@27);
            }
            make.trailing.equalTo(@(-13));
            make.height.equalTo(@24);
        }];
        
        [self.skipLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@2);
            make.leading.mas_equalTo(self.btn.mas_leading).offset(10);
            make.centerY.mas_equalTo(self.btn.mas_centerY);
        }];
        
        [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@(-2));
            make.leading.mas_equalTo(self.skipLab.mas_trailing);
            make.trailing.mas_equalTo(self.btn.mas_trailing).offset(-10);
            make.centerY.mas_equalTo(self.btn.mas_centerY);
        }];
        
        
    }
    return self;
}

#pragma mark

- (void)timerAction {
    //埋点
    if (_time == 2) {
        
    }
   
    _time --;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.timeLab.text = [NSString stringWithFormat:@"S%d", _time];
    } else {
        self.timeLab.text = [NSString stringWithFormat:@"%dS", _time];
    }
    if (_time == 0) {
        [self removeadvertImgView];
    }
}

- (void)skipAction {
    if (self.skipBlock) {
        self.skipBlock();
    }
    [self removeadvertImgView];
}

- (void)removeadvertImgView
{
    [_timer invalidate];
    _timer = nil;
    
    [UIView animateWithDuration:1.0 animations:^{
        //self.transform = CGAffineTransformScale(self.transform, 2, 2);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.hidden = YES;
        
        if (self.advDoActionBlock) {
            self.advDoActionBlock(nil);
       
        }
    }];
}


- (void)advertImgViewDoAction {
    STLLog(@"📋广告图📋");
    
    
    [_timer invalidate];
    _timer = nil;
   
    [_advertImgView removeFromSuperview];
    _advertImgView = nil;
    [self removeFromSuperview];
    self.hidden = YES;
    
    if (self.advDoActionBlock) {
        self.advDoActionBlock(_EventModel);
    }
}

#pragma mark - LazyLoad

- (YYAnimatedImageView *)advertImgView {
    if (!_advertImgView) {
        _advertImgView = [[YYAnimatedImageView alloc] initWithFrame:WINDOW.bounds];
        _advertImgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _advertImgView.userInteractionEnabled = YES;
    }
    return _advertImgView;
}

- (UIButton *)btn {
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //                    btn.titleLabel.font = [self SDFontWithFamilyName:_ParagraphFontName_ size:15];
        _btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        //                    [btn setTitle:@"Skip\n4S" forState:0];
        //                    [btn setTitleColor:[UIColor redColor] forState:0];
        //                    [btn setTitleColor:[UIColor redColor] forState:1];
        _btn.backgroundColor = [OSSVThemesColors col_0D0D0D:0.5];
        _btn.layer.cornerRadius = 12;
        _btn.layer.masksToBounds = YES;
        _btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_btn addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _btn;
}

- (UILabel *)skipLab {
    if (!_skipLab) {
        _skipLab = [[UILabel alloc] init];
        _skipLab.font = [UIFont systemFontOfSize:11];
        _skipLab.textAlignment = NSTextAlignmentCenter;
        _skipLab.textColor = [OSSVThemesColors stlWhiteColor];
        _skipLab.text = STLLocalizedString_(@"skip",nil);
    }
    return _skipLab;
}

- (UILabel *)timeLab {
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] init];
        _timeLab.tag = 321456;
        _timeLab.font = [UIFont systemFontOfSize:11];
        _timeLab.textAlignment = NSTextAlignmentCenter;
        _timeLab.textColor = [OSSVThemesColors stlWhiteColor];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _timeLab.text = @"S2";
        } else {
            _timeLab.text = @"2S";

        }
    }
    return _timeLab;
}

@end
