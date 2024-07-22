//
//  CouponItemViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/6/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CouponItemViewModel.h"
#import "CouponItemApi.h"
#import "CouponItemModel.h"
#import "CouponItemCell.h"
#import "ZFBannerModel.h"
#import "BannerManager.h"
#import "NSStringUtils.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "ZFGrowingIOAnalytics.h"
#import "ZFLocalizationString.h"
#import "ZFCouponListItemAOP.h"

@interface CouponItemViewModel ()
@property (nonatomic, strong) NSNumber *currentTime;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation CouponItemViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:[[ZFCouponListItemAOP alloc] init]];
    }
    return self;
}

- (void)requestCouponItemPageData:(BOOL)isFirstPage
                       completion:(void (^)(NSDictionary *pageInfo))completion
{
    if (isFirstPage) {
        self.currentPage = 1;
    } else {
        self.currentPage = ++self.currentPage;
    }
    CouponItemApi *api = [[CouponItemApi alloc] initWithKind:self.kind page:self.currentPage pageSize:15];
    
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            NSArray *tempArray = [NSArray yy_modelArrayWithClass:[CouponItemModel class] json:requestJSON[ZFResultKey][@"data"]];
            
            if (self.currentPage == 1) {
                self.dataSource = [NSMutableArray arrayWithArray:tempArray];
            } else {
                [self.dataSource addObjectsFromArray:tempArray];
            }
            self.currentTime = requestJSON[ZFResultKey][@"now_time"];
            self.currentPage = [requestJSON[ZFResultKey][@"page"] integerValue];
            self.totalPage = [requestJSON[ZFResultKey][@"total_page"] integerValue];
            // 成功清空新优惠券提示
            [AccountManager sharedManager].account.has_new_coupon = @"0";
            [APPDELEGATE.tabBarVC isShowNewCouponDot];
            
        }
        
        if (completion) {
            NSDictionary *pageInfo = @{ kTotalPageKey  : @(self.totalPage),
                                        kCurrentPageKey: @(self.currentPage) };
            completion(pageInfo);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        --self.currentPage;
        if (completion) {
            completion(nil);
        }
    }];
}

#pragma mark - product cell delegate

-(void)ZFAccountProductCellDidSelectProduct:(ZFGoodsModel *)goodsModel
{
    if (self.goodsClickBlock) {
        self.goodsClickBlock(goodsModel);
    }
}

#pragma mark - tablegateDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.contentType == CouponListContentType_RecommendList) {
        return self.recommendDataList.count + 1;
    } else {
        return self.dataSource.count;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.contentType == CouponListContentType_RecommendList) {
        if (indexPath.section == 0) {
            //第一个为title cell
            ZFTitleTableViewCell *titleCell = [tableView dequeueReusableCellWithIdentifier:kZFCouponListTitleCellIdentifier];
            if (!titleCell) {
                titleCell = [[ZFTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kZFCouponListTitleCellIdentifier];
            }
            titleCell.title = ZFLocalizedString(@"Account_RecomTitle", nil);
            return titleCell;
        } else {
            NSString *idetifier = [NSString stringWithFormat:@"%@",kZFCouponListProductCellIdentifier];
            ZFAccountProductCell *productCell = [tableView dequeueReusableCellWithIdentifier:idetifier];
            if (!productCell) {
                productCell = [[ZFAccountProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idetifier abFlag:1];
            }
            productCell.goodsList = self.recommendDataList[indexPath.section - 1];
            productCell.delegate = self;
            return productCell;
        }
    } else {
        CouponItemCell *cell = [CouponItemCell couponItemCellWithTableView:tableView indexPath:indexPath];
        cell.currentTime = self.currentTime;
        cell.couponType  = [self.kind integerValue];
        cell.couponModel = self.dataSource[indexPath.section];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CouponItemModel *couponModel = self.dataSource[indexPath.section];
        cell.tagBtnActionHandle = ^{
            couponModel.isShowAll = !couponModel.isShowAll;
            [self.dataSource replaceObjectAtIndex:indexPath.section withObject:couponModel];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        cell.userItActionHandle = ^{
            NSURL *banner_url = [NSURL URLWithString:NullFilter(couponModel.deeplink_uri)];
            NSString *scheme = [banner_url scheme];
            if ([scheme isEqualToString:kZZZZZScheme]) {
                NSMutableDictionary *paramDict = [BannerManager parseDeeplinkParamDicWithURL:banner_url];
                paramDict[@"coupon"] = NullFilter(couponModel.code);
                [BannerManager jumpDeeplinkTarget:self.controller deeplinkParam:paramDict];
            }
            
            [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Click_UseIt_%@", couponModel.code] itemName:@"User It" ContentType:@"My - Coupon" itemCategory:@"Button"];
            
            [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOFistEvar : GIOSourceAccount,
                                                       GIOSndNameEvar : GIOSourceCoupon
            }];
        };
        
        return cell;
    }
}
@end
