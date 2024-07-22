//
//  ZFVideoCommentListView.h
//  ZZZZZ
//
//  Created by YW on 2019/8/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYText.h"
#import "ZFZegoMessageInfo.h"
#import "ZFZegoSettings.h"
#import "ZFVideoLiveCommentUtils.h"
#import "ZFFrameDefiner.h"

#import <ZegoLiveRoom/ZegoLiveRoomApiDefines-IM.h>



@interface ZFVideoLiveCommentListView : UIView

- (instancetype)initWithFrame:(CGRect)frame isNew:(BOOL)isNew;

@property (nonatomic, strong) UIView            *topMessageView;

@property (nonatomic, strong) UIButton          *messageTipButton;

@property (nonatomic, strong) UITableView       *messageTable;

@property (strong, nonatomic) dispatch_source_t messageTimer;

@property (nonatomic, assign) BOOL              isNoNeedTimer;
@property (nonatomic, assign) BOOL              isNoDataHideMessageList;



@property (nonatomic, assign) NSInteger         timeCount;

@property (nonatomic, assign) BOOL              isHorizontalState;
@property (nonatomic, assign) BOOL              hasMoved;
@property (nonatomic, assign) BOOL              isLive;
@property (nonatomic, copy) NSString            *liveID;

@property (nonatomic, assign) CGFloat contentOffsetY;


+ (CGFloat)newLiveCommentListWidth;
/// 刷新组件处理
- (void)addTableViewRefreshKit;
- (void)hideTableViewRefreshKit;

/// 顶部移动消息时间事件
- (void)startMessageTimer;
- (void)cancelMessageTimer;

/// 刷新数据处理
- (void)reloadView;
- (void)upateTipMessage:(NSString *)tipMsg;

/// 滚动事件处理
- (void)scrollTableViewToBottom;
- (void)scrollTableViewToTop;

- (void)scrollCurrentContnetOffSetY;

@end



@interface ZFVideoLiveCommentMessageCell : UITableViewCell

@property (nonatomic, strong) UILabel              *contentLabel;
@property (nonatomic, strong) NSAttributedString   *layout;

@end



@interface ZFVideoLiveCommentMessageNewCell : UITableViewCell

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel              *contentLabel;
@property (nonatomic, strong) NSAttributedString   *layout;

@end

