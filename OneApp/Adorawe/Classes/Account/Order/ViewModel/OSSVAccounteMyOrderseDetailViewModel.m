//
//  OSSVAccounteMyOrderseDetailViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/20.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteMyOrderseDetailViewModel.h"

//订单详情Api
#import "OSSVAccounteMyOrderseDetailAip.h"

//支付订单Api
#import "OSSVAccountePayeMyOrdersAip.h"

//取消订单Api
#import "OSSVAccounteCanceleMyOrdersAip.h"

//模型数据
#import "OSSVOrderInfoeModel.h"
#import "OSSVAccounteMyOrderseDetailModel.h"

@interface OSSVAccounteMyOrderseDetailViewModel ()

@property (nonatomic,strong) OSSVAccounteMyOrderseDetailModel *detailModel;

@property (nonatomic,strong) OSSVOrderInfoeModel *OSSVOrderInfoeModel;

@property (nonatomic,strong) OSSVOrdereInforeModel *orderInfoModeVl452;

@property (nonatomic,strong) NSArray *dataArray;

@end

//详情页是否转菊花
#define TURN_HUD 0

@implementation OSSVAccounteMyOrderseDetailViewModel

/*========================================分割线======================================*/

- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVAccounteMyOrderseDetailAip *api = [[OSSVAccounteMyOrderseDetailAip alloc] initWithOrderId:parmaters];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            self.detailModel = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(self.detailModel);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil);
            }
        }];
        [self.queueList addObject:api];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

/*========================================分割线======================================*/

#pragma mark - 取消订单
- (void)requestCancelOrder:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        OSSVAccounteCanceleMyOrdersAip *api = [[OSSVAccounteCanceleMyOrdersAip alloc] initWithOrderId:parmaters];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            if (completion) {
                completion(nil);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            STLLog(@"failure");
        }];
        [self.queueList addObject:api];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

/*========================================分割线======================================*/

#pragma mark - 在线支付订单
- (void)requestPayNowOrder:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVAccountePayeMyOrdersAip *api = [[OSSVAccountePayeMyOrdersAip alloc] initWithOrderId:parmaters];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            OSSVOrdereInforeModel *model = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(model);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil);
            }
            STLLog(@"failure");
        }];
        [self.queueList addObject:api];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

/*========================================分割线======================================*/

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[OSSVAccounteMyOrderseDetailAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVAccounteMyOrderseDetailModel yy_modelWithJSON:json[kResult]];
        } else if ([request isKindOfClass:[OSSVAccounteCanceleMyOrdersAip class]]) {
            if ([json[kStatusCode] integerValue] == kStatusCode_200) {
                [self alertMessage:json[@"message"]];
            } else {
                [self alertMessage:@"Cancel the failure!"];
            }
        }
    }else if ([request isKindOfClass:[OSSVAccountePayeMyOrdersAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            //进行数据解析，如果订单生成成功，此处应该返回一个支付链接
            self.orderInfoModeVl452 = [OSSVOrdereInforeModel yy_modelWithJSON:json[kResult]];
//            self.OSSVOrderInfoeModel = [OSSVOrderInfoeModel yy_modelWithJSON:json[kResult][@"order_info"]];
            if (self.orderInfoModeVl452) {
                return self.orderInfoModeVl452;
            } else {
                return nil;
            }
        }else {
            [self alertMessage:json[@"message"]];
            return nil;
        }
    }
    return nil;
}

/*========================================分割线======================================*/

#pragma mark - DZNEmptyDataSetSource Methods
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    self.emptyViewManager.customNoDataView = [self makeCustomNoDataView];
    return [self.emptyViewManager accordingToTypeReBackView:self.emptyViewShowType];
}


/*========================================分割线======================================*/

#pragma mark make - privateCustomView(NoDataView)
- (UIView *)makeCustomNoDataView {
    UIView * customView = [[UIView alloc] initWithFrame:CGRectZero];
    customView.backgroundColor = [UIColor whiteColor];
    
    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
    imageView.image = [UIImage imageNamed:@"request_out"];
    [customView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(customView.mas_top).offset(105);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = OSSVThemesColors.col_333333;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.text = STLLocalizedString_(@"request_out", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [customView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH - 30);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [OSSVThemesColors col_262626];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:STLLocalizedString_(@"refresh", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(emptyOperationTouch) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3;
    [customView addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(30);
        make.centerX.mas_equalTo(customView.mas_centerX);
        make.width.mas_equalTo(@180);
        make.height.mas_equalTo(@40);
    }];
    return customView;
}

/*========================================分割线======================================*/

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
    return 0;
}

/*========================================分割线======================================*/

@end
