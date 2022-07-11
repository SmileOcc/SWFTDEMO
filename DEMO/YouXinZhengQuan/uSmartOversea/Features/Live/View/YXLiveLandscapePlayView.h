//
//  YXLiveLandscapePlayView.h
//  uSmartOversea
//
//  Created by suntao on 2021/2/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@import TXLiteAVSDK_Professional;

@class YXLiveDetailModel;

NS_ASSUME_NONNULL_BEGIN

@interface YXLiveLandscapePlayView : UIView

@property (nonatomic, assign) BOOL isPlaying;

//@property (nonatomic, strong) UILabel *watchCountLabel;
//@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) void(^playBlock)(BOOL isPlay);

@property (nonatomic, strong) void(^toLoginBlock)(void);
@property (nonatomic, strong) void(^closeBlock)(void);
@property (nonatomic, strong) NSString *showUrl;

@property (nonatomic, strong, nullable) TXLivePlayer *txLivePlayer;
@property (nonatomic, strong) YXLiveDetailModel *liveModel;

-(void)showTopBottomView;
-(void)closeCommentTimer;
-(void)updateCommentFromLogin;

@end

NS_ASSUME_NONNULL_END
