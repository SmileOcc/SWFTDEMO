//
//  ZFVideoCommentListView.m
//  ZZZZZ
//
//  Created by YW on 2019/8/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFVideoLiveCommentListView.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "NSStringUtils.h"
#import "ZFCommunityLiveViewModel.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"

#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFCommunityRefreshHeader.h"

static NSInteger kZFVideoLiveCommentTopFirstTag = 20191020;
static NSInteger kZFVideoLiveCommentTopSecondTag = 20191021;
static NSInteger kZFVideoLiveCommentTopMoveHeight = 28;

@interface ZFVideoLiveCommentListView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIButton *tempMoveMessageButton;

@property (nonatomic, strong) ZFCommunityLiveViewModel          *liveViewModel;

@property (nonatomic, assign) BOOL                              isDraging;

@property (nonatomic, assign) CGFloat                           lastOffSetY;

@property (nonatomic, strong) NSIndexPath                       *showLastIndexPath;
@property (nonatomic, strong) NSIndexPath                       *tempShowLastIndexPath;


@property (nonatomic, assign) NSInteger testtt;

@property (nonatomic, assign) BOOL                               isTopMessageMoving;

@property (nonatomic, assign) BOOL                               isNewCell;




@end

@implementation ZFVideoLiveCommentListView


- (void)dealloc {
    YWLog(@"----dealloc: %@",NSStringFromClass(self.class));
}

- (instancetype)initWithFrame:(CGRect)frame isNew:(BOOL)isNew{
    self = [super initWithFrame:frame];
    if (self) {
        self.isNewCell = isNew;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.messageTable];
        [self addSubview:self.topMessageView];
        [self addSubview:self.messageTipButton];
        self.testtt = 10;
        
        [self.messageTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(self);
            make.top.mas_equalTo(self.mas_top);
        }];
        
        [self.topMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(16);
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(28);
        }];
        
        
        [self.messageTipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
            make.height.mas_equalTo(28);
        }];
        
    }
    return self;
}

+ (CGFloat)newLiveCommentListWidth {
    CGFloat minW = MIN(KScreenWidth, KScreenHeight);
    return minW * 3.0 / 4.0;
}
- (void)startRequestHistoryListMore:(BOOL)loadMore {
    
    if ([ZFVideoLiveCommentUtils sharedInstance].isLoadingRequest) {
        [self.messageTable.mj_header endRefreshing];
        return;
    }
    
    if (self.liveViewModel.historyCanNotRefresh) {
        [self.messageTable.mj_header endRefreshing];
        return;
    }
    
    NSString *liveId = [ZFVideoLiveCommentUtils sharedInstance].liveDetailID;
    NSDictionary *dic = @{@"firstpage":@(loadMore),@"liveID":ZFToString(liveId)};
    
    @weakify(self)
    [self.liveViewModel requestCommunityLiveHistory:dic completion:^(ZFCommunityLiveZegoHistoryMessageModel *messagModels) {
        @strongify(self)
        
        YWLog(@"----kkkkkkk %@   %@",self,[ZFVideoLiveCommentUtils sharedInstance].historyMessageList);
        if (self.liveViewModel.historyCurPage == 1) {
            [[ZFVideoLiveCommentUtils sharedInstance].liveMessageList removeAllObjects];
            [[ZFVideoLiveCommentUtils sharedInstance].historyMessageList removeAllObjects];
        }
        if (ZFJudgeNSArray(messagModels.list)) {
            if (messagModels.list.count > 0) {
                //因为数据排序问题，需要反向排序处理
                NSArray *dataMsgs=(NSArray *)[[messagModels.list reverseObjectEnumerator] allObjects];
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataMsgs.count)];
                [[ZFVideoLiveCommentUtils sharedInstance].liveMessageList insertObjects:dataMsgs atIndexes:indexSet];
                [[ZFVideoLiveCommentUtils sharedInstance].historyMessageList addObjectsFromArray:dataMsgs];
            }
        }
        
        // 为了显示空视图
        [[ZFVideoLiveCommentUtils sharedInstance] refreshCommentNotif:@"scrollToTop"];
        
        [self.messageTable.mj_header endRefreshing];
        [ZFVideoLiveCommentUtils sharedInstance].isLoadingRequest = NO;
    }];
}

#pragma mark - 消息横向滚动

- (void)startMessageTimer {
    [self cancelMessageTimer];
    
    if (self.isNoNeedTimer) {
        return;
    }
    
    // 队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    // 创建 dispatch_source
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 声明成员变量
    self.messageTimer = timer;
    // 设置两秒后触发
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
    // 设置下次触发事件为 DISPATCH_TIME_FOREVER
    dispatch_time_t nextTime = DISPATCH_TIME_FOREVER;
    // 设置精确度
    dispatch_time_t leeway = 0.1 * NSEC_PER_SEC;
    // 配置时间
    dispatch_source_set_timer(timer, startTime, nextTime, leeway);
    // 回调
    dispatch_source_set_event_handler(timer, ^{
        
        //[self testMoveMessage]; // 测试移动消息
        [self moveTopMessageAnimate];
    });
    // 激活
    dispatch_resume(self.messageTimer);
    
}

- (void)testMoveMessage {

#ifdef DEBUG
    if (self.timeCount < self.testtt) {
        YWLog(@"-----直播消息  %li",(long)self.timeCount);
        ZFZegoMessageInfo *mesInfo = [[ZFZegoMessageInfo alloc] init];
        mesInfo.type = @"6";
        mesInfo.nickname = @"occc";
        
        mesInfo.content = [NSString stringWithFormat:@"-%li ccccddd ccccddd ccccddd",(long)[ZFVideoLiveCommentUtils sharedInstance].topShowMessageList.count];
        [[[ZFVideoLiveCommentUtils sharedInstance] topShowMessageList] addObject:mesInfo];
    } else {
        self.testtt--;
        if (self.testtt <= 0) {
            self.testtt = [ZFVideoLiveCommentUtils sharedInstance].topShowMessageList.count + 15;
        }
        
    }
#endif
}

- (UIButton *)createTopMovieMessageView {
    UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(-10, (28 - kZFVideoLiveCommentTopMoveHeight) / 2.0, 0, kZFVideoLiveCommentTopMoveHeight)];
    messageButton.titleLabel.font = [UIFont systemFontOfSize:14];
    messageButton.layer.cornerRadius = kZFVideoLiveCommentTopMoveHeight / 2.0;
    messageButton.layer.masksToBounds = YES;
    messageButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    return messageButton;
}

- (UIColor *)movieMessageBgColor:(ZegoMessageInfoType)type {
    if (type == ZegoMessageInfoTypePay) {//付款成功
        return ZFC0xE0FFD6();
    } else if (type == ZegoMessageInfoTypeOrder) {//下单成功
        return ZFC0xFFE4E4();
    }
    return ZFC0xFFF3E4();//添加购物车
}

- (UIColor *)movieMessageUserNameColor:(ZegoMessageInfoType)type {
    if (type == ZegoMessageInfoTypePay) {//付款成功
        return ZFC0x21CB0D();
    } else if (type == ZegoMessageInfoTypeOrder) {//下单成功
        return ZFC0xFF6B6B();
    }
    return ZFC0xE3A321();//添加购物车
}

- (UIColor *)messageUserNameColor:(NSInteger)index {
    if (index == 0) {
        return ZFC0x2DA4FF();
        
    } else if(index == 1) {
        return ZFC0x31CCE3();

    } else if(index == 2) {
        return ZFC0xFB9139();

    } else if(index == 3) {
        return ZFC0xF75DCA();

    }
    return ZFC0x2DA4FF();
}


- (void)cancelMessageTimer {
    if (self.messageTimer) {
        dispatch_source_cancel(self.messageTimer);
    }
}


- (void)moveTopMessageAnimate {
    
    if (!self.superview) {
        [self cancelMessageTimer];
        return;
    }
    
    if (self.isTopMessageMoving) {
        return;
    }
    
    NSMutableArray *msgs = [[ZFVideoLiveCommentUtils sharedInstance] topShowMessageList];
    if (msgs.count > self.timeCount) {
        if ([ZFVideoLiveCommentUtils sharedInstance].topShowIndex < self.timeCount) {
            [ZFVideoLiveCommentUtils sharedInstance].topShowIndex = self.timeCount;
        } else if ([ZFVideoLiveCommentUtils sharedInstance].topShowIndex > self.timeCount){
            self.timeCount = [ZFVideoLiveCommentUtils sharedInstance].topShowIndex;
        }
    }
    
    if (self.isHidden) {//隐藏状态下，不显示
        [self startMessageTimer];
        return;
    }
    
    if (msgs.count >= ([ZFVideoLiveCommentUtils sharedInstance].topShowIndex + 1)) {
        
        // 创建
        UIButton *firstButton = [self.topMessageView viewWithTag:kZFVideoLiveCommentTopFirstTag];
        if (!firstButton) {
            firstButton = [self createTopMovieMessageView];
            firstButton.tag = kZFVideoLiveCommentTopFirstTag;
            [self.topMessageView addSubview:firstButton];
            
            CGFloat width = CGRectGetWidth(self.topMessageView.frame);
            [firstButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.topMessageView.mas_leading).offset(-(width + 50));
                make.centerY.mas_equalTo(self.topMessageView.mas_centerY);
                make.width.mas_lessThanOrEqualTo(width - 50);
                make.height.mas_equalTo(kZFVideoLiveCommentTopMoveHeight);
            }];
        }
        
        UIButton *secondButton = [self.topMessageView viewWithTag:kZFVideoLiveCommentTopSecondTag];
        if (!secondButton) {
            secondButton = [self createTopMovieMessageView];
            secondButton.tag = kZFVideoLiveCommentTopSecondTag;
            [self.topMessageView addSubview:secondButton];
            
            CGFloat width = CGRectGetWidth(self.topMessageView.frame);
            [secondButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.topMessageView.mas_leading).offset(-(width + 50));
                make.centerY.mas_equalTo(self.topMessageView.mas_centerY);
                make.width.mas_lessThanOrEqualTo(width - 50);
                make.height.mas_equalTo(kZFVideoLiveCommentTopMoveHeight);
            }];
        }
        
        // 数据、动画处理
        if (!self.tempMoveMessageButton) {
            [self moveAnimateView:firstButton content:msgs[[ZFVideoLiveCommentUtils sharedInstance].topShowIndex]];
            
        } else if (self.tempMoveMessageButton.tag == firstButton.tag) {
            [self moveAnimateView:secondButton content:msgs[[ZFVideoLiveCommentUtils sharedInstance].topShowIndex]];
            [self moveAnimateHideView:firstButton];

        } else if (self.tempMoveMessageButton.tag == secondButton.tag) {
            [self moveAnimateView:firstButton content:msgs[[ZFVideoLiveCommentUtils sharedInstance].topShowIndex]];
            [self moveAnimateHideView:secondButton];
        }
        
    } else {
        [self startMessageTimer];
        self.tempMoveMessageButton.hidden = YES;
    }
}

- (void)moveAnimateView:(UIButton *)msgButton content:(ZFZegoMessageInfo *)messageInfo{
    
    [ZFVideoLiveCommentUtils sharedInstance].isTopMessageMoving = YES;
    self.isTopMessageMoving = YES;
    msgButton.backgroundColor = [self movieMessageBgColor:messageInfo.infoType];
    [msgButton setAttributedTitle:[self handelMessageInfo:messageInfo topMoveTitle:YES] forState:UIControlStateNormal];
    msgButton.alpha = 1.0;
    msgButton.hidden = NO;
    [UIView animateWithDuration:0.4 animations:^{
        [msgButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.topMessageView.mas_leading);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.timeCount++;
        YWLog(@"--------move end: %li",(long)self.timeCount);
        [ZFVideoLiveCommentUtils sharedInstance].topShowIndex = self.timeCount;
        [ZFVideoLiveCommentUtils sharedInstance].isTopMessageMoving = NO;
        self.isTopMessageMoving = NO;
        [self startMessageTimer];
    }];
    
    self.tempMoveMessageButton = msgButton;
}

- (void)moveAnimateHideView:(UIButton *)msgButton {
    
    CGFloat width = CGRectGetWidth(self.topMessageView.frame);
    [UIView animateWithDuration:0.2 animations:^{
        msgButton.alpha = 0.5;
    } completion:^(BOOL finished) {
        [msgButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.topMessageView.mas_leading).offset(-(width + 50));
        }];
        [self layoutIfNeeded];
    }];
}

#pragma mark - 消息刷新

- (void)addTableViewRefreshKit {
    
    if (!self.messageTable.mj_header) {
        
        @weakify(self);
        [self.messageTable addCommunityHeaderRefreshBlock:^{
            @strongify(self);
            [self startRequestHistoryListMore:YES];
            
        } footerRefreshBlock:^{
            
        } startRefreshing:YES];
        self.messageTable.mj_footer.hidden = YES;
    } else {
        self.messageTable.mj_header.hidden = NO;
    }
}

- (void)hideTableViewRefreshKit {
    if (self.messageTable.mj_header) {
        self.messageTable.mj_header.hidden = YES;
    }
}


- (void)reloadView {
    [self.messageTable reloadData];
    if (!self.isHorizontalState) {
        if (!self.liveViewModel.historyCanNotRefresh) {
            [self.messageTable showRequestTip:@{}];
        } else {
            
            if ([self.messageTable.mj_header isKindOfClass:[ZFCommunityRefreshHeader class]]) {
                ZFCommunityRefreshHeader *header = (ZFCommunityRefreshHeader *)self.messageTable.mj_header;
                [header setHeaderTipMessage:ZFLocalizedString(@"Global_Network_No_MoreData", nil)];
            }
            [self.messageTable showRequestTip:@{}];
        }
    }
    self.contentOffsetY = self.messageTable.contentOffset.y;
}

- (void)upateTipMessage:(NSString *)tipMsg {
    if (ZFIsEmptyString(tipMsg)) {
        self.messageTipButton.hidden = YES;
    } else {
        [self.messageTipButton setTitle:tipMsg forState:UIControlStateNormal];
        [_messageTipButton zfLayoutStyle:ZFButtonEdgeInsetsStyleRight imageTitleSpace:2];
        self.messageTipButton.hidden = NO;
    }
}

- (void)actionMessageTip:(UIButton *)sender {
    self.hasMoved = NO;
    [self reloadView];
    [self scrollTableViewToBottom];
}


- (NSMutableAttributedString *)handelMessageInfo:(ZFZegoMessageInfo *)messageInfo topMoveTitle:(BOOL)topMove {
    
    NSMutableAttributedString *totalText = [[NSMutableAttributedString alloc] init];
    
    if (messageInfo.infoType == ZegoMessageInfoTypeCart
        || messageInfo.infoType == ZegoMessageInfoTypeOrder
        || messageInfo.infoType == ZegoMessageInfoTypePay) {
        NSMutableAttributedString *userNameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", ZFToString(messageInfo.nickname)]];
        
        userNameString.yy_font = [UIFont systemFontOfSize:14.0];
        userNameString.yy_color = [self movieMessageUserNameColor:messageInfo.infoType];
        
        [totalText appendAttributedString:userNameString];
        
        NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:ZFToString(messageInfo.content)];
        contentString.yy_font = [UIFont systemFontOfSize:14.0];
        contentString.yy_color = ZFC0x999999();
        
        [totalText appendAttributedString:contentString];
    }
    
    return totalText;
}

/// v5.4.0进入用户直播，订单相关信息都灰置
- (NSMutableAttributedString *)handelMessageInfo:(ZFZegoMessageInfo *)messageInfo index:(NSInteger)index{

    NSMutableAttributedString *normalText = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *sepcialText = [[NSMutableAttributedString alloc] init];

    if (messageInfo.infoType == ZegoMessageInfoTypeUser) {
        
        if (ZFIsEmptyString(messageInfo.normalAttributeString.string)) {
            
            NSMutableAttributedString *userNameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", ZFToString(messageInfo.nickname)]];
            
            userNameString.yy_font = [UIFont systemFontOfSize:14.0];
            userNameString.yy_color = ZFC0x999999();
            
            [normalText appendAttributedString:userNameString];
            [sepcialText appendAttributedString:userNameString];
            
            NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:ZFLocalizedString(@"Live_Enter_Room", nil)];
            contentString.yy_font = [UIFont systemFontOfSize:14.0];
            contentString.yy_color = ZFC0x999999();
            
            NSMutableAttributedString *sepcialString = [[NSMutableAttributedString alloc] initWithString:ZFLocalizedString(@"Live_Enter_Room", nil)];
            sepcialString.yy_font = [UIFont systemFontOfSize:14.0];
            sepcialString.yy_color = ZFC0x999999();
            
            [normalText appendAttributedString:contentString];
            [sepcialText appendAttributedString:sepcialString];
            
            messageInfo.normalAttributeString = normalText;
            messageInfo.specialAttributeString = sepcialText;
        }
        
        
    } else if (messageInfo.infoType == ZegoMessageInfoTypeCart
        || messageInfo.infoType == ZegoMessageInfoTypeOrder
        || messageInfo.infoType == ZegoMessageInfoTypePay) {
        
         if (ZFIsEmptyString(messageInfo.normalAttributeString.string)) {
             
             NSMutableAttributedString *userNameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", ZFToString(messageInfo.nickname)]];
             
             userNameString.yy_font = [UIFont systemFontOfSize:14.0];
             userNameString.yy_color = [self movieMessageUserNameColor:messageInfo.infoType];
             
             [normalText appendAttributedString:userNameString];
             [sepcialText appendAttributedString:userNameString];

             NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:ZFToString(messageInfo.content)];
             contentString.yy_font = [UIFont systemFontOfSize:14.0];
             contentString.yy_color =  ZFC0x999999();
             
             NSMutableAttributedString *sepcialString = [[NSMutableAttributedString alloc] initWithString:ZFToString(messageInfo.content)];
             sepcialString.yy_font = [UIFont systemFontOfSize:14.0];
             sepcialString.yy_color = ZFC0x999999();
             
             [normalText appendAttributedString:contentString];
             [sepcialText appendAttributedString:sepcialString];

             messageInfo.normalAttributeString = normalText;
             messageInfo.specialAttributeString = sepcialText;
         }
        
    } else if(messageInfo.infoType == ZegoMessageInfoTypeComment
              || messageInfo.infoType == ZegoMessageInfoTypeSystem){
        
        if (ZFIsEmptyString(messageInfo.normalAttributeString)) {

            if (messageInfo.infoType == ZegoMessageInfoTypeSystem) {
                
                NSMutableAttributedString *userNameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", ZFToString(messageInfo.nickname)]];
                userNameString.yy_font = [UIFont systemFontOfSize:14.0];
                userNameString.yy_color = ZFC0x999999();
                
                
                NSMutableAttributedString *specialUserNameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", ZFToString(messageInfo.nickname)]];
                
                specialUserNameString.yy_font = [UIFont systemFontOfSize:14.0];
                specialUserNameString.yy_color = ZFC0xFFFFFF();
                
                [normalText appendAttributedString:userNameString];
                [sepcialText appendAttributedString:specialUserNameString];
                
            } else {
                
                NSMutableAttributedString *userNameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", ZFToString(messageInfo.nickname)]];
                
                userNameString.yy_font = [UIFont systemFontOfSize:14.0];
                userNameString.yy_color = [self messageUserNameColor:index];
                
                [normalText appendAttributedString:userNameString];
                [sepcialText appendAttributedString:userNameString];
            }

            NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:ZFToString(messageInfo.content)];
            contentString.yy_font = [UIFont systemFontOfSize:14.0];
            if (self.isNewCell) {
                contentString.yy_color = ZFC0xFFFFFF();
            } else {
                contentString.yy_color = ZFC0x2D2D2D();
            }
            
            NSMutableAttributedString *sepcialString = [[NSMutableAttributedString alloc] initWithString:ZFToString(messageInfo.content)];
            sepcialString.yy_font = [UIFont systemFontOfSize:14.0];
            sepcialString.yy_color = ZFC0xFFFFFF();
            
            [normalText appendAttributedString:contentString];
            [sepcialText appendAttributedString:sepcialString];
            
            messageInfo.normalAttributeString = normalText;
            messageInfo.specialAttributeString = sepcialText;
        }
        
    }
    
    if (ZFIsEmptyString(messageInfo.normalAttributeString.string)) {
        return normalText;
    }
    return self.isHorizontalState ? messageInfo.specialAttributeString : messageInfo.normalAttributeString;
}

- (void)scrollTableViewToBottom {
    
    if (self.hasMoved) {
        
        if (_showLastIndexPath) {
            if (_showLastIndexPath.row >= _tempShowLastIndexPath.row) {
                
                NSInteger notShowCount = [ZFVideoLiveCommentUtils sharedInstance].liveMessageList.count - _showLastIndexPath.row - 1;
                if (notShowCount > 0) {
                    NSString *tipTitle = [NSString stringWithFormat:@"%li %@",(long)notShowCount,ZFLocalizedString(@"Live_Messages", nil)];
                    if (notShowCount >= 100) {
                        tipTitle = [NSString stringWithFormat:@"%i+ %@",99,ZFLocalizedString(@"Live_Messages", nil)];
                    }
                    [self upateTipMessage:tipTitle];
                } else {
                    [self upateTipMessage:@""];
                    self.hasMoved = NO;
                }
            }
        }
        
        return;
    }
    
    if (self.isDraging) {
        return;
    }
    
    [self upateTipMessage:@""];

    NSInteger lastItemIndex = [self.messageTable numberOfRowsInSection:0] - 1;
    if (lastItemIndex < 0) {
        return;
    }
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastItemIndex inSection:0];
    [self.messageTable scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    self.contentOffsetY = self.messageTable.contentOffset.y;
}

- (void)scrollTableViewToTop {
    if (self.isDraging) {
        return;
    }
    
    NSInteger itemIndex = [self.messageTable numberOfRowsInSection:0];
    if ([ZFVideoLiveCommentUtils sharedInstance].liveMessageList.count > 0 && itemIndex > 0) {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.messageTable scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        self.hasMoved = NO;
        self.showLastIndexPath = nil;
        [self upateTipMessage:@""];
        
        self.contentOffsetY = self.messageTable.contentOffset.y;
    }
}

- (void)scrollCurrentContnetOffSetY {
    if (self.contentOffsetY > 0) {
        [self.messageTable setContentOffset:CGPointMake(0, self.contentOffsetY) animated:NO];
    }
}


#pragma mark - UITableView DataSource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([ZFVideoLiveCommentUtils sharedInstance].liveMessageList.count == 0 && self.isNoDataHideMessageList) {
        tableView.hidden = YES;
    } else if(tableView.isHidden) {
        tableView.hidden = NO;
    }
    return [ZFVideoLiveCommentUtils sharedInstance].liveMessageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSString *cellID;
    if (self.isNewCell) {
        cellID = NSStringFromClass(ZFVideoLiveCommentMessageNewCell.class);
    } else {
        cellID = NSStringFromClass(ZFVideoLiveCommentMessageCell.class);
    }
    ZFVideoLiveCommentMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;

    
    if (indexPath.row < [ZFVideoLiveCommentUtils sharedInstance].liveMessageList.count) {
        ZFZegoMessageInfo *messageInfo = [ZFVideoLiveCommentUtils sharedInstance].liveMessageList[indexPath.row];
        cell.layout = [self handelMessageInfo:messageInfo index:indexPath.row % 4];
    }
    if (!_showLastIndexPath) {
        _showLastIndexPath = indexPath;
        _tempShowLastIndexPath = indexPath;
    } else {
        if (_showLastIndexPath.row < indexPath.row) {
            _showLastIndexPath = indexPath;
            _tempShowLastIndexPath = indexPath;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row >= [ZFVideoLiveCommentUtils sharedInstance].liveMessageList.count - 2) {
        self.messageTipButton.hidden = YES;
        self.hasMoved = NO;
        return;
    }
    
    if (_showLastIndexPath) {
        if (_showLastIndexPath.row >= indexPath.row) {
            return;
        }
    }
    
    if (_tempShowLastIndexPath) {
        if (_tempShowLastIndexPath.row >= indexPath.row) {
            return;
        }
    }
    if (self.hasMoved) {
        NSInteger notShowCount = [ZFVideoLiveCommentUtils sharedInstance].liveMessageList.count - indexPath.row - 1;
        if (notShowCount > 0) {
            NSString *tipTitle = [NSString stringWithFormat:@"%li New Messages",(long)notShowCount];
            if (notShowCount >= 100) {
                tipTitle = [NSString stringWithFormat:@"%i+ New Messages",99];
            }
            [self upateTipMessage:tipTitle];
        } else {
            [self upateTipMessage:@""];
            self.hasMoved = NO;
        }
    }
    
}




- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetY = scrollView.contentOffset.y;
    YWLog(@"------- %f",offsetY);
    
    if (self.isDraging) {// 这个只处理拖拽
        self.contentOffsetY = offsetY;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    YWLog(@"-----scrollViewDidEndDecelerating：%f",scrollView.contentOffset.y);
    self.contentOffsetY = scrollView.contentOffset.y;
    
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    self.isDraging = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastOffSetY = scrollView.contentOffset.y;
    
    CGFloat contentSizeH = scrollView.contentSize.height;
    CGFloat sizeH = CGRectGetHeight(scrollView.frame);
    if (contentSizeH > sizeH) {
        self.hasMoved = YES;
    }
    self.isDraging = YES;
}
#pragma mark - Property Method


- (ZFCommunityLiveViewModel *)liveViewModel {
    if (!_liveViewModel) {
        _liveViewModel = [[ZFCommunityLiveViewModel alloc] init];
    }
    return _liveViewModel;
}

- (UIView *)topMessageView {
    if (!_topMessageView) {
        _topMessageView = [[UIView alloc] initWithFrame:CGRectZero];
        _topMessageView.layer.masksToBounds = YES;
    }
    return _topMessageView;
}

- (UITableView *)messageTable {
    if (!_messageTable) {
        _messageTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _messageTable.delegate = self;
        _messageTable.dataSource = self;
        _messageTable.rowHeight = UITableViewAutomaticDimension;
        _messageTable.estimatedRowHeight = 220;
        _messageTable.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _messageTable.backgroundColor = ZFCClearColor();
        _messageTable.showsVerticalScrollIndicator = NO;
        _messageTable.showsHorizontalScrollIndicator = NO;

        [_messageTable registerClass:[ZFVideoLiveCommentMessageCell class] forCellReuseIdentifier:NSStringFromClass(ZFVideoLiveCommentMessageCell.class)];
        [_messageTable registerClass:[ZFVideoLiveCommentMessageNewCell class] forCellReuseIdentifier:NSStringFromClass(ZFVideoLiveCommentMessageNewCell.class)];
        
        _messageTable.emptyDataTitle = @"";
        _messageTable.emptyDataImage = [UIImage imageNamed:@"blankPage_noMeaagess"];
    }
    return _messageTable;
}

- (UIButton *)messageTipButton {
    if (!_messageTipButton) {
        _messageTipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _messageTipButton.layer.cornerRadius = 14.0;
        _messageTipButton.layer.masksToBounds = YES;
        _messageTipButton.backgroundColor = ZFC0x0080F3_07();
        [_messageTipButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        [_messageTipButton setImage:[UIImage imageNamed:@"live_arrow_down"] forState:UIControlStateNormal];
        _messageTipButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_messageTipButton addTarget:self action:@selector(actionMessageTip:) forControlEvents:UIControlEventTouchUpInside];
        _messageTipButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        [_messageTipButton zfLayoutStyle:ZFButtonEdgeInsetsStyleRight imageTitleSpace:2];
        _messageTipButton.hidden = YES;
    }
    return _messageTipButton;
}
@end



#pragma mark -

@implementation ZFVideoLiveCommentMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.contentLabel];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.contentView.mas_top).offset(5);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        }];
    }
    
    return self;
}

- (void)setLayout:(NSAttributedString *)layout {
    self.contentLabel.attributedText = layout;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _contentLabel;
}

@end


#pragma mark -

@implementation ZFVideoLiveCommentMessageNewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.bgView];
        [self.contentView addSubview:self.contentLabel];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat minW = [ZFVideoLiveCommentListView newLiveCommentListWidth];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(10);
            make.width.mas_lessThanOrEqualTo(minW - 80);
            make.top.mas_equalTo(self.contentView.mas_top).offset(5);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        }];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentLabel.mas_leading).offset(-10);
            make.trailing.mas_equalTo(self.contentLabel.mas_trailing).offset(10);
            make.top.mas_equalTo(self.contentLabel.mas_top).offset(-2);
            make.bottom.mas_equalTo(self.contentLabel.mas_bottom).offset(2);
            make.height.mas_greaterThanOrEqualTo(28);
        }];
    }
    
    return self;
}

- (void)setLayout:(NSAttributedString *)layout {
    self.contentLabel.attributedText = layout;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = ZFC0x000000_A(0.2);
        _bgView.layer.cornerRadius = 14;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _contentLabel;
}

@end
