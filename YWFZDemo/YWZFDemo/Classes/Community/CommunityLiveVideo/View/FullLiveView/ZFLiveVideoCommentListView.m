//
//  ZFLiveVideoCommentListView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFLiveVideoCommentListView.h"
#import "ZFBaseViewController.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFInitViewProtocol.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "GZFInputTextView.h"
#import "ZFVideoLiveCommentUtils.h"

#import "ZFFullLiveCommentCell.h"
@interface ZFLiveVideoCommentListView()
<
UITableViewDelegate,
UITableViewDataSource,
ZFInitViewProtocol>

@property (nonatomic, strong) UIView                                *contentView;
@property (nonatomic, strong) UIView                                *topBarView;
@property (nonatomic, strong) UILabel                               *titleLabel;
@property (nonatomic, strong) UIButton                              *closeButton;
@property (nonatomic, strong) UITableView                           *tableView;


@property (nonatomic, strong) UIView                                *bottomView;
@property (nonatomic, strong) UITextView                            *textView;
@property (nonatomic, strong) UILabel                               *textPlaceLabel;
@property (nonatomic, strong) UIButton                              *sendTextButton;
@property (nonatomic, strong) UIView                                *lineView;

/** 弹出输入视图*/
@property (nonatomic, strong) GZFInputTextView                      *inputTextView;
@property (nonatomic, strong) UIButton                              *inputTextButton;

@property (nonatomic, assign) BOOL                                  isDraging;
@property (nonatomic, assign) CGFloat                               contentOffsetY;

@end

@implementation ZFLiveVideoCommentListView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(8, 8)];
}

- (void)zfViewWillAppear {
    
}

- (void)zfInitView {
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.topBarView];
    [self.contentView addSubview:self.tableView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.closeButton];
    [self.contentView addSubview:self.bottomView];
    
    [self.bottomView addSubview:self.textView];
    [self.bottomView addSubview:self.textPlaceLabel];
    [self.bottomView addSubview:self.inputTextButton];
    [self.bottomView addSubview:self.sendTextButton];
    [self.bottomView addSubview:self.lineView];
    
           
}

- (CGFloat)contentH {
    return [ZFVideoLiveConfigureInfoUtils liveShowViewHeight];
}

- (void)zfAutoLayoutView {
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self contentH]);
        make.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset([self contentH]);
    }];
    
    [self.topBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(44);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.topBarView.mas_bottom);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.topBarView.mas_centerX);
        make.centerY.mas_equalTo(self.topBarView.mas_centerY);
        make.width.mas_lessThanOrEqualTo(KScreenWidth - 80);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.topBarView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.topBarView.mas_centerY);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tableView.mas_bottom);
        make.leading.trailing.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(49);
    }];
    
    [self.sendTextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        make.width.mas_lessThanOrEqualTo(100);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bottomView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.sendTextButton.mas_leading).offset(-12);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        make.height.mas_equalTo(37);
    }];
    
    [self.inputTextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.textView);
    }];
    
    [self.textPlaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.textView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.textView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.textView.mas_centerY);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.bottomView);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)requestPageData:(BOOL)firstPage {
    //occ测试数据 请求数据
//    @weakify(self)
//    [self.viewModel requestCollectGoodsPageData:firstPage completion:^(ZFCollectionListModel *listModel, NSArray *currentPageArray, NSDictionary *pageInfo) {
//        @strongify(self)
//        if (firstPage && !currentPageArray.count) {
//            if (self.styleViewdelegate && [self.styleViewdelegate respondsToSelector:@selector(ZFWishListVerticalStyleViewNoData)]) {
//                [self.styleViewdelegate ZFWishListVerticalStyleViewNoData];
//            }
//        } else {
//            self.listModel = listModel;
            [self.tableView reloadData];
//            [self showRequestTip:pageInfo];
//        }
//    }];
}

- (void)fullScreen:(id)isFull {
    if (![isFull boolValue]) {
        [self scrollCurrentContnetOffSetY];
    }
}

- (void)showCommentListView:(BOOL)show {
    
    CGFloat topX;
    if (show) {
        topX = 0;
        self.hidden = NO;
        self.backgroundColor = ZFC0x000000_A(0);
    } else {
        topX = [self contentH];
    }
    
    [self setNeedsUpdateConstraints];
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.userInteractionEnabled = YES;
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(topX);
        }];
        self.backgroundColor = show ? ZFC0x000000_A(0.4) : ZFC0x000000_A(0);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = !show;
    }];
}

- (void)actionClose:(UIButton *)sender {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (void)actionSendText:(UIButton *)sender {
    
    if (!ZFIsEmptyString(self.textView.text)) {
        [self sendCommentMsg:self.textView.text];
    }
}

- (void)actionText:(UIButton *)sender {
    //occ测试数据
    if ([AccountManager sharedManager].isSignIn) {
        self.inputTextView.textView.text = ZFToString([ZFVideoLiveCommentUtils sharedInstance].inputText);
        [self.inputTextView showTextView];
        
    } else {
        //此处只登录
        [self isOperateLoginBlock:^{
            
        }];
    }

    
}

- (void)sendCommentMsg:(NSString *)contentMsg {
    if (!ZFIsEmptyString(contentMsg)) {
        [self endEditing:YES];
        
        NSString *phase = [ZFVideoLiveCommentUtils sharedInstance].isLoginRoom ? @"1" : @"0";
        NSString *nickName = [ZFVideoLiveCommentUtils sharedInstance].nickName;
        
        //occ测试数据 发送评论
//        [self.liveViewModel requestCommunityLiveCommentLiveID:[ZFVideoLiveCommentUtils sharedInstance].liveDetailID liveType:[ZFVideoLiveCommentUtils sharedInstance].isLoginRoom ? @"1" : @"0" content:contentMsg nickname:ZFToString(nickName) phase:phase completion:^(BOOL success, NSString *msg) {
//            if (success) {
//                YWLog(@"---- 直播评论成功");
//
//                
//                /// 未登录时，自己添加
//                if (![ZFVideoLiveCommentUtils sharedInstance].isLoginRoom) {
//                    ZFZegoMessageInfo *message = [[ZFZegoMessageInfo alloc] init];
//                    message.type = @"4";
//                    message.nickname = ZFToString([AccountManager sharedManager].account.nickname);
//                    message.content = ZFToString(contentMsg);
//                    [[ZFVideoLiveCommentUtils sharedInstance] addMessage:message];
//                }
//
//                self.textView.text = @"";
//                [self.sendTextButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
//                
//                [ZFVideoLiveCommentUtils sharedInstance].inputText = @"";
//                [[ZFVideoLiveCommentUtils sharedInstance] sendCommentSuccessNotif];
//                [[ZFVideoLiveCommentUtils sharedInstance] refreshInputTextNotif];
//            } else {
//                self.textView.text = [ZFVideoLiveCommentUtils sharedInstance].inputText;
//                [self.sendTextButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
//                ShowToastToViewWithText(self, msg);
//            }
//        }];
        
        
    }
}

- (void)isOperateLoginBlock:(void (^)(void))completion {
    
    if ([AccountManager sharedManager].isSignIn) {
        if (completion) {
            completion();
        }
        
    } else {
        
        UIViewController *ctrl = self.viewController;
        if ([ctrl isKindOfClass:[ZFBaseViewController class]]) {
            ZFBaseViewController *baseCtrl = (ZFBaseViewController *)ctrl;
            if (baseCtrl.navigationController) {
                ZFNavigationController *nav = (ZFNavigationController *)baseCtrl.navigationController;
                if (nav.interfaceOrientation == UIInterfaceOrientationLandscapeRight || nav.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                    
                    [baseCtrl forceOrientation:AppForceOrientationPortrait];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        baseCtrl.isStatusBarHidden = NO;
                        [self.viewController judgePresentLoginVCCompletion:^{
                            baseCtrl.isStatusBarHidden = YES;
                            if (completion) {
                                completion();
                            }
                        } cancelCompetion:^{
                            baseCtrl.isStatusBarHidden = YES;
                        }];
                    });
                    
                    
                } else {
                    
                    baseCtrl.isStatusBarHidden = NO;
                    [self.viewController judgePresentLoginVCCompletion:^{
                        baseCtrl.isStatusBarHidden = YES;
                        if (completion) {
                            completion();
                        }
                    } cancelCompetion:^{
                        baseCtrl.isStatusBarHidden = YES;
                    }];
                }
            }
        }
    }
}


- (void)updateCommentContnet:(NSString *)text {
    if (!ZFIsEmptyString(text)) {
        self.textPlaceLabel.hidden = YES;
        self.textView.text = text;
        [self.sendTextButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [ZFVideoLiveCommentUtils sharedInstance].inputText = text;
        
    } else {
        self.textPlaceLabel.hidden = NO;
        self.textView.text = @"";
        [self.sendTextButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        [ZFVideoLiveCommentUtils sharedInstance].inputText = @"";
    }
}

- (void)scrollCurrentContnetOffSetY {
    if (self.contentOffsetY > 0) {
        [self.tableView setContentOffset:CGPointMake(0, self.contentOffsetY) animated:NO];
    }
}

//- (void)updateHotActivity:(NSArray<ZFCommunityLiveVideoRedNetModel *>*)activityModel {
//    if (ZFJudgeNSArray(activityModel)) {
//        self.liveActivityViewModel.datasArray = [[NSMutableArray alloc] initWithArray:activityModel];
//        [self.collectionView reloadData];
//        self.contentOffsetY = self.collectionView.contentOffset.y;
//    }
//
//    [self.collectionView showRequestTip:@{kTotalPageKey  : @(1),
//                                          kCurrentPageKey: @(1)}];
//}

- (void)requestLiveGoodsPageData:(BOOL)isFirstPage {
    // 不请求数据
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFFullLiveCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ZFFullLiveCommentCell.class)];
    
    cell.nameLabel.text = @"fodjafdojaf";
    if (indexPath.row == 0) {
        cell.messageLabel.text = @"faojfdijai fjdiajfidjaifjdsaifidafidfidj fdjaifjdaifji fdiajfi jfdiajfidjfi jfdiaj fidajf ijfdiajfia";
    } else if(indexPath.row == 3) {
        cell.messageLabel.text = @"";
    }
    else if(indexPath.row == 4) {
           cell.messageLabel.text = @"aojfdijai fjdiajfid";
       }
    else if(indexPath.row == 5) {
        cell.messageLabel.text = @"aojfdijai fjdiajfid aojfdijai fjdiajfid aojfdijai fjdiajfid aojfdijai fjdiajfid aojfdijai fjdiajfid aojfdijai fjdiajfid aojfdijai fjdiajfid aojfdijai fjdiajfid aojfdijai fjdiajfid aojfdijai fjdiajfid aojfdijai fjdiajfid aojfdijai fjdiajfid";
    } else {
        cell.messageLabel.text = @"doajfdef";
    }
    
    return cell;
}

#pragma mark - UIScrollView
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
    self.isDraging = YES;
}
#pragma mark - Property Method

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = ZFC0xFFFFFF();
    }
    return _contentView;
}

- (UIView *)topBarView {
    if (!_topBarView) {
        _topBarView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _topBarView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFC0x2D2D2D();
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = ZFLocalizedString(@"Live_Comment", nil);
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"z-me_outfits_post_close"] forState:UIControlStateNormal];
        _closeButton.contentEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.alwaysBounceVertical = YES;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 220;
        _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        
        _tableView.emptyDataTitle = @"";
        _tableView.emptyDataImage = [UIImage imageNamed:@"blankPage_noMeaagess"];

        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_tableView registerClass:[ZFFullLiveCommentCell class] forCellReuseIdentifier:NSStringFromClass(ZFFullLiveCommentCell.class)];
    
        @weakify(self)
        [_tableView addHeaderRefreshBlock:^{
            @strongify(self)
            [self requestPageData:YES];
        } footerRefreshBlock:nil startRefreshing:YES];
    
    }
    return _tableView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _bottomView;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.backgroundColor = ZFC0xF7F7F7();
        _textView.layer.cornerRadius = 2.0;
        _textView.layer.masksToBounds = YES;
        _textView.textColor = ZFC0x2D2D2D();
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.editable = NO;
    }
    return _textView;
}

- (UILabel *)textPlaceLabel {
    if (!_textPlaceLabel) {
        _textPlaceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textPlaceLabel.textColor = ZFC0xCCCCCC();
        _textPlaceLabel.font = [UIFont systemFontOfSize:14];
        _textPlaceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _textPlaceLabel.text = ZFLocalizedString(@"Live_Review_Input_tip", nil);
    }
    return _textPlaceLabel;
}

- (UIButton *)sendTextButton {
    if (!_sendTextButton) {
        _sendTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendTextButton setTitle:@"send" forState:UIControlStateNormal];
        [_sendTextButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        _sendTextButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_sendTextButton addTarget:self action:@selector(actionSendText:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _sendTextButton;
}

- (GZFInputTextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[GZFInputTextView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _inputTextView.texeEditBlock = ^(NSString *text) {
            @strongify(self)
            //occ测试数据
            [self updateCommentContnet:text];
            [[ZFVideoLiveCommentUtils sharedInstance] refreshInputTextNotif];
        };
        
        _inputTextView.sendTextBlock = ^(NSString * _Nonnull text) {
            @strongify(self)
            //occ测试数据
            [self sendCommentMsg:text];
        };
        
    }
    return _inputTextView;
}

- (UIButton *)inputTextButton {
    if (!_inputTextButton) {
        _inputTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_inputTextButton addTarget:self action:@selector(actionText:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _inputTextButton;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = ZFC0xDDDDDD();
    }
    return _lineView;
}
@end
