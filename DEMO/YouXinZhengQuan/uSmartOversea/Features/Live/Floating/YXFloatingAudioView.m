//
//  YXFloatingAudioView.m
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/11/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXFloatingAudioView.h"
#import "UIGestureRecognizer+YYAdd.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>


@interface YXFloatingAudioView ()

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UIButton *statusButton;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, copy) NSDictionary *paramsJson;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation YXFloatingAudioView

+ (YXFloatingAudioView *)sharedView {
    static YXFloatingAudioView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YXFloatingAudioView alloc] init];
        [UIApplication.sharedApplication.keyWindow.rootViewController.view addSubview:instance];
    });
    
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 120, 420)];
    if (self) {
        self.backgroundColor = [UIColor qmui_colorWithHexString:@"#D4D4D4"];
        self.layer.cornerRadius = 21;
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.iconView];
        [self addSubview:self.statusButton];
        [self addSubview:self.closeButton];
        
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(4);
            make.centerY.equalTo(self);
            make.width.height.mas_equalTo(36);
        }];
        
        [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(4);
            make.centerY.equalTo(self);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-12);
            make.centerY.equalTo(self);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(loginOut) name:YXUserManager.notiLoginOut object:nil];
        
    }
    return self;
}

- (UIImageView *)iconView {
    if (_iconView == nil) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        _iconView.layer.cornerRadius = 18;
        _iconView.layer.masksToBounds = YES;
        _iconView.userInteractionEnabled = YES;
        
        @weakify(self)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @strongify(self)
            if (self.paramsJson) {
                NSString *urlString = self.paramsJson[@"url"];
                NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:urlString];
                NSMutableArray *queryItems = [urlComponents.queryItems mutableCopy];
                if (queryItems == nil) {
                    queryItems = [NSMutableArray array];
                }
                for (NSURLQueryItem *item in queryItems) {
                    if ([item.name isEqualToString:@"timing"]) {
                        [queryItems removeObject:item];
                        break;
                    }
                }
                CMTime time = self.player.currentTime;
                NSInteger seek = (NSInteger)(time.value / time.timescale);
                [queryItems addObject: [NSURLQueryItem queryItemWithName:@"timing" value:@(seek).stringValue]];
                urlComponents.queryItems = queryItems;
                NSURL *url = urlComponents.URL;
       
                [YXWebViewModel pushToWebVC:url.absoluteString];
            }
        }];
        [_iconView addGestureRecognizer:tap];
    }
    return _iconView;
}

- (UIButton *)statusButton {
    if (_statusButton == nil) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_statusButton setImage:[UIImage imageNamed:@"floating_audio_pause"] forState:UIControlStateNormal];
        [_statusButton setImage:[UIImage imageNamed:@"floating_audio_play"] forState:UIControlStateSelected];
        [_statusButton addTarget:self action:@selector(statusClicked) forControlEvents:UIControlEventTouchUpInside];
        _statusButton.adjustsImageWhenHighlighted = NO;
    }
    return _statusButton;
}

- (UIButton *)closeButton {
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"floating_audio_close"] forState:UIControlStateNormal];
        _closeButton.adjustsImageWhenHighlighted = NO;
        [_closeButton addTarget:self action:@selector(closeClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (void)closeClicked {
    [self hideFloating];
}

- (void)statusClicked {
    if (self.statusButton.isSelected) {
        [self.player play];
        self.statusButton.selected = NO;
    } else {
        [self.player pause];
        self.statusButton.selected = YES;
    }
}

- (void)resetFrame {
    CGFloat originX = YXConstant.screenWidth - 120 - 14;
    CGFloat originY = YXConstant.screenHeight - 42 - self.freeRect.size.height/5;
    self.frame = CGRectMake(originX, originY, 120, 42);
}

- (void)startH5Play:(NSDictionary *)paramsJson {
    self.paramsJson = paramsJson;
    if (self.paramsJson) {
        self.hidden = NO;

        [self resetFrame];
        
        NSString *imageUrl = self.paramsJson[@"coverImage"];
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];

        NSURL* url = [NSURL URLWithString:self.paramsJson[@"playUrl"]];
        self.playerItem = [AVPlayerItem playerItemWithURL:url];
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        // 静音下能播放音频
        NSError *setCategoryError = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    }
}

- (void)hideFloating {
    self.hidden = YES;
    self.paramsJson = nil;
    
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.player pause];
    }

    self.playerItem = nil;
    self.player = nil;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void*)context{
    
    if([object isKindOfClass:[AVPlayerItem class]]) {
        if([keyPath isEqualToString:@"status"]) {
            switch(_playerItem.status) {
                case AVPlayerItemStatusReadyToPlay: {
                   NSNumber *seek = self.paramsJson[@"seek"];
                   if (seek && [seek integerValue] > 0) {
                       [self.player play];
                       NSMutableDictionary *dict = [self.paramsJson mutableCopy];
                       dict[@"seek"] = @(0);
                       self.paramsJson = dict;
                       CMTime time = self.player.currentTime;
                       time.value = [seek integerValue] * time.timescale;
                       [self.player seekToTime:time completionHandler:^(BOOL finished) {
                           if (finished) {
                               [self.player play];
                           }
                       }];
                   } else {
                       [self.player play];
                   }
                }
                    break;
                case AVPlayerItemStatusUnknown:
                    NSLog(@"AVPlayerItemStatusUnknown");
                    break;
                case AVPlayerItemStatusFailed:
                    NSLog(@"AVPlayerItemStatusFailed");
                    break;
                default:
                    break;
            }
        }
    }
}

// 屏幕旋转通知回调
- (void)orientationDidChange:(NSNotification *)notification {
    
    if (!CGSizeEqualToSize(self.freeRect.size, self.superview.bounds.size)) {
        CGRect oldFreeRect = self.freeRect;
        self.freeRect = (CGRect){CGPointZero,self.superview.bounds.size};

        CGFloat originX = self.frame.origin.x;
        CGFloat originY = self.frame.origin.y;
        
        CGFloat centerX = oldFreeRect.origin.x + (oldFreeRect.size.width - self.frame.size.width)/2;
        CGFloat centerY = oldFreeRect.origin.y + (oldFreeRect.size.height - self.frame.size.height)/2;
        
        if (originX > centerX) {
            originX = self.freeRect.size.width - self.frame.size.width - 22;
        } else {
            originX = 22;
        }
        
        if (originY > centerY) {
            originY = self.freeRect.size.height - self.frame.size.height - self.freeRect.size.height/4;
        } else {
            originY = self.freeRect.size.height/4;
        }
        
        self.frame = (CGRect){CGPointMake(originX, originY),self.bounds.size};
    }
}

- (void)loginOut {
    [self hideFloating];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
