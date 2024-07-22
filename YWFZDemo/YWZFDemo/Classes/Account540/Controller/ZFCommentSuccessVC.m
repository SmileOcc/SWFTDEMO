//
//  ZFCommentSuccessVC.m
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommentSuccessVC.h"
#import "ZFCommentListViewModel.h"
#import "ZFWaitCommentCell.h"
#import "ZFWriteReviewViewController.h"
#import "ZFCartViewController.h"

#import "CouponItemViewModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "YYText.h"
#import "NSStringUtils.h"
#import "ExchangeManager.h"

@interface ZFCommentSuccessVC () <ZFInitViewProtocol, UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) YYLabel *pointTipLabel;
@property (nonatomic, strong) UIImageView *footerImageView;
@property (nonatomic, strong) NSMutableArray<ZFWaitCommentModel *> *modelArray;
@property (nonatomic, strong) ZFCommentListViewModel *viewModel;
@end

@implementation ZFCommentSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Submitted Successfully";
    self.view.backgroundColor = ZFC0xF2F2F2();
    self.fd_interactivePopDisabled = YES;
    
    [self zfInitView];
    [self zfAutoLayoutView];
    [self loadCommentPageData];
    
    ///删除导航栈中相同的控制器
    [self deleteVCFromNavgation:[ZFWriteReviewViewController class]];
}

- (void)setResultModel:(ZFWriteReviewResultModel *)resultModel {
    _resultModel = resultModel;
    
    self.tableHeaderView.hidden = NO;
    
    NSString *youhuilv = ZFToString(resultModel.review.review_success_coupon.youhuilv);
    NSString *fangshi = ZFToString(resultModel.review.review_success_coupon.fangshi);
    NSString *pontsMsg = ZFToString(resultModel.review.review_success_point);
    NSString *couponMsg = [ExchangeManager localCouponContent:@"USD" youhuilv:youhuilv fangshi:fangshi];
    
    if (!ZFIsEmptyString(couponMsg)) {
        
        NSString *youhuilv__1 = ZFToString(resultModel.review.review_success_coupon1.youhuilv);
        NSString *fangshi__1 = ZFToString(resultModel.review.review_success_coupon1.fangshi);
        NSString *couponMsg__11 = [ExchangeManager localCouponContent:@"USD" youhuilv:youhuilv__1 fangshi:fangshi__1];
        
        NSString *contentStr;
        
        if (!ZFIsEmptyString(youhuilv__1) && !ZFIsEmptyString(couponMsg__11)) {
            contentStr = [NSString stringWithFormat:ZFLocalizedString(@"Order_Comment_Send_Account_XXPoints_XXCoupon_XXCoupon", nil),pontsMsg,couponMsg,couponMsg__11];

        } else {
            
            contentStr = [NSString stringWithFormat:ZFLocalizedString(@"Order_Comment_Send_Account_XXPoints_XXCoupon", nil),pontsMsg,couponMsg];
        }
        
        
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:contentStr];
        
        content.yy_font = ZFFontSystemSize(14.0);
        content.yy_color = ZFC0x2D2D2D();
        
        NSRange pointsRange = [NSStringUtils rangeSpecailString:contentStr specialString:pontsMsg];
        if (pointsRange.location != NSNotFound) {
            [content yy_setColor:ZFC0xFE5269() range:pointsRange];
        }
        
        NSRange rewardRange = [NSStringUtils rangeSpecailString:contentStr specialString:couponMsg];
        if (rewardRange.location != NSNotFound) {
            [content yy_setColor:ZFC0xFE5269() range:rewardRange];
        }
        
        // 第二个优惠券
        if (!ZFIsEmptyString(youhuilv__1) && !ZFIsEmptyString(couponMsg__11)) {
            NSArray *rangesDicArray = [NSStringUtils calculateSubStringCount:contentStr str:couponMsg__11];
            if (rangesDicArray.count > 0) {
                NSDictionary *dic = rangesDicArray.lastObject;
                NSInteger location = [dic[@"location"] integerValue];
                NSInteger length = [dic[@"length"] integerValue];
                NSRange tempRange = NSMakeRange(location, length);
                
                if (tempRange.location != NSNotFound) {
                    [content yy_setColor:ZFC0xFE5269() range:tempRange];
                }
            }
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [content addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,contentStr.length)];
        
        self.pointTipLabel.attributedText = content;
    } else {
        
        NSString *contentStr = [NSString stringWithFormat:ZFLocalizedString(@"Order_Comment_Send_Account_XXPoints", nil),pontsMsg];
        
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:contentStr];
        content.yy_font = ZFFontSystemSize(14.0);
        content.yy_color = ZFC0x2D2D2D();
        
        NSRange pointsRange = [NSStringUtils rangeSpecailString:contentStr specialString:pontsMsg];
        if (pointsRange.location != NSNotFound) {
            [content yy_setColor:ZFC0xFE5269() range:pointsRange];
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [content addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,contentStr.length)];
        self.pointTipLabel.attributedText = content;
    }
}

#pragma mark - Private Method

- (void)loadCommentPageData {
    @weakify(self)
    [self.viewModel requestWaitCommentPort:YES completion:^(NSArray *modelArray) {
        @strongify(self)
        [self.modelArray removeAllObjects];
        [self.modelArray addObjectsFromArray:modelArray];
        [self.tableView reloadData];
        [self configFooterView];
    }];
}

- (void)configFooterView {
    if (self.modelArray.count == 0) {
        UIImage *image = [UIImage imageNamed:@"order_review_success_banner"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, KScreenWidth, image.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        @weakify(self)
        [imageView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self)
            [self goshoppingAction];
        }];
        self.tableView.tableFooterView = imageView;
    } else {
        self.tableView.tableFooterView = nil;
    }
}

#pragma mark - Jump Method
- (ZFNavigationController *)queryTargetNavigationController:(NSInteger)index {
    ZFTabBarController *tabBarVC = APPDELEGATE.tabBarVC;
    if (tabBarVC.selectedIndex != index) {
        ZFNavigationController  *currentNavVC = (ZFNavigationController *)tabBarVC.selectedViewController;
        [currentNavVC popToRootViewControllerAnimated:NO];
        tabBarVC.selectedIndex = index;
    }
    ZFNavigationController  *targetNavVC = (ZFNavigationController *)tabBarVC.selectedViewController;
    return targetNavVC;
}

//继续购物
- (void)goshoppingAction {
    ZFNavigationController *accountNavVC = [self queryTargetNavigationController:TabBarIndexAccount];
    
    ZFCartViewController *cartVC = [[ZFCartViewController alloc] init];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    NSNumber *cartCount = GetUserDefault(kCollectionBadgeKey);
    if (cartCount.integerValue > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [accountNavVC pushViewController:cartVC animated:YES];
        });
    } else {
        ZFTabBarController *tabBarVC = APPDELEGATE.tabBarVC;
        [tabBarVC setZFTabBarIndex:TabBarIndexHome];
    }
}

- (void)reviewActionWithModel:(ZFWaitCommentModel *)commentModel {
    ZFWriteReviewViewController *vc = [[ZFWriteReviewViewController alloc] init];
    vc.commentModel = commentModel;
    [self.navigationController pushViewController:vc animated:YES];
    
    [self deleteVCFromNavgation:[self class]];
}

///删除导航栈中指定的控制器
- (void)deleteVCFromNavgation:(Class)className {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *subVCArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        
        for (UIViewController *subVC in self.navigationController.viewControllers) {
            if ([subVC isKindOfClass:className]){
                [subVCArray removeObject:subVC];
                break;
            }
        }
        [self.navigationController setViewControllers:subVCArray animated:YES];
    });
}

#pragma mark - tablegateDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.modelArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect rect = CGRectMake(0, 0, KScreenWidth, 50);
    UILabel *sectionTipLabel = [[UILabel alloc] initWithFrame:rect];
    sectionTipLabel.backgroundColor = [UIColor whiteColor];
    sectionTipLabel.font = [UIFont systemFontOfSize:14];
    sectionTipLabel.textColor = ZFCOLOR(45, 45, 45, 1);
    sectionTipLabel.textAlignment = NSTextAlignmentCenter;
    sectionTipLabel.text = ZFLocalizedString(@"Order_Comment_Earn_More_Points", nil);
    return sectionTipLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZFWaitCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFWaitCommentCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.commentModel = self.modelArray[indexPath.row];
    @weakify(self);
    cell.touchReviewBlock = ^(ZFWaitCommentModel * _Nonnull model) {
        @strongify(self);
        [self reviewActionWithModel:model];
    };
    return cell;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

#pragma mark - getter
-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle                 = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor                = [UIColor whiteColor];
        _tableView.showsVerticalScrollIndicator   = YES;
        _tableView.rowHeight                      = 125;
        _tableView.dataSource                     = self;
        _tableView.delegate                       = self;
        _tableView.contentInset                   = UIEdgeInsetsMake(0, 0, kiphoneXHomeBarHeight, 0);
        _tableView.emptyDataTitle                 = ZFLocalizedString(@"NewVersionGuide_GoShopping",nil);
        _tableView.emptyDataImage                 = ZFImageWithName(@"blankPage_noCoupon");
        _tableView.tableHeaderView                = self.tableHeaderView;
        
        [_tableView registerClass:[ZFWaitCommentCell class] forCellReuseIdentifier:NSStringFromClass([ZFWaitCommentCell class])];
    }
    return _tableView;
}

- (NSMutableArray<ZFWaitCommentModel *> *)modelArray {
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}

- (ZFCommentListViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommentListViewModel alloc]init];
    }
    return _viewModel;
}

- (UIView *)tableHeaderView {
    if (!_tableHeaderView) {
        CGRect rect = CGRectMake(0, 0, KScreenWidth, 200);
        _tableHeaderView = [[UIView alloc] initWithFrame:rect];
        _tableHeaderView.backgroundColor = [UIColor whiteColor];
        _tableHeaderView.userInteractionEnabled = YES;
        
        CGRect topTipRect = CGRectMake(0, 0, KScreenWidth, 35);
        YYLabel *topTipLabel = [[YYLabel alloc] initWithFrame:topTipRect];
        topTipLabel.backgroundColor = ZFC0xF2F2F2();
        topTipLabel.font = [UIFont systemFontOfSize:14];
        topTipLabel.textColor = ZFC0x999999();
        topTipLabel.numberOfLines = 0;
        topTipLabel.text = ZFLocalizedString(@"Order_Comment_Success_Top_Tips_XXPoints", nil);
        CGSize fitSize = [topTipLabel sizeThatFits:CGSizeMake(KScreenWidth, CGFLOAT_MAX)];
        topTipLabel.mj_h = fitSize.height + 10;
        topTipLabel.textContainerInset = UIEdgeInsetsMake(5, 12, 5, 12);
        [_tableHeaderView addSubview:topTipLabel];
        
        
        CGRect imageRect = CGRectMake((KScreenWidth - 50 )/2, CGRectGetMaxY(topTipLabel.frame)+30, 50, 50);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageRect];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:@"comment_success"];
        [_tableHeaderView addSubview:imageView];
        
        
        CGRect tipRect = CGRectMake(35, CGRectGetMaxY(imageView.frame)+22, KScreenWidth - 70, 35);
        YYLabel *pointTipLabel = [[YYLabel alloc] initWithFrame:tipRect];
        pointTipLabel.backgroundColor = [UIColor whiteColor];
        pointTipLabel.font = [UIFont systemFontOfSize:14];
        pointTipLabel.textColor = ZFCOLOR(254, 82, 105, 1);
        pointTipLabel.numberOfLines = 2;//限制2行
        pointTipLabel.textAlignment = NSTextAlignmentCenter;
        pointTipLabel.preferredMaxLayoutWidth = KScreenWidth - 24 * 2;
        [_tableHeaderView addSubview:pointTipLabel];
        pointTipLabel.text = @"";
        self.pointTipLabel = pointTipLabel;
        
        CGRect lineRect = CGRectMake(0, CGRectGetMaxY(pointTipLabel.frame)+12, KScreenWidth, 12);
        UIView *view = [[UIView alloc] initWithFrame:lineRect];
        view.backgroundColor = ZFC0xF2F2F2();
        [_tableHeaderView addSubview:view];
        
        _tableHeaderView.mj_h = CGRectGetMaxY(view.frame);
    }
    return _tableHeaderView;
}

@end
