//
//  OSSVCartCouponItemViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartCouponItemViewModel.h"

#import "OSSVMysCouponItemsCell.h"

#import "OSSVCartCouponSelectAip.h"

#import "OSSVCartCouponSelectModel.h"

#import "OSSVMyCouponsListsModel.h"
#import "OSSVCartSelectCouponVC.h"

@interface OSSVCartCouponItemViewModel ()



@property (nonatomic,strong) OSSVCartCouponSelectModel *selectModel;

@end


@implementation OSSVCartCouponItemViewModel

- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        OSSVCartCouponSelectAip *api = [[OSSVCartCouponSelectAip alloc] initWithGoodsList:parmaters];
        @weakify(self)
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            self.selectModel = [self dataAnalysisFromJson: requestJSON request:api];
            self.available = self.selectModel.available;
            self.unavailable = self.selectModel.unavailable;
            
            for (OSSVMyCouponsListsModel *model in self.available) {
                if ([self.couponCode.uppercaseString isEqualToString:model.couponCode.uppercaseString]) {
                    model.isSelected = YES;
                    break;
                }
            }
            
            //自定义标记不可用
            [self.unavailable enumerateObjectsUsingBlock:^(OSSVMyCouponsListsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.unAvailabel = YES;
            }];
            
            if (self.available.count > 0 && self.unavailable.count > 0) {
                self.emptyViewShowType = EmptyViewShowTypeHide;
            }else {
                self.emptyViewShowType = EmptyViewShowTypeNoData;
            }
            
            if (completion) {
                completion(@(self.emptyViewShowType));
            }
            
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            @strongify(self)
            if (self.available.count > 0 && self.unavailable.count > 0) {
                self.emptyViewShowType = EmptyViewShowTypeHide;
            }else {
                self.emptyViewShowType = EmptyViewShowTypeNoNet;
            }
            if (failure) {
                failure(error);
            }
        }];
    } exception:^{
        @strongify(self)
        self.emptyViewShowType = EmptyViewShowTypeNoNet;
        if (failure) {
            failure(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request{
    if ([request isKindOfClass:[OSSVCartCouponSelectAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVCartCouponSelectModel yy_modelWithJSON:json[kResult]];
        }
    }
    return nil;
}

#pragma mark
#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (tableView.tag) {
        case AvaliableViewTagSpecial:
        {
            return self.available.count;
        }
            break;
        default:
        {
            return self.unavailable.count;
        }
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (tableView.tag) {
        case AvaliableViewTagSpecial:
        {
            OSSVMysCouponItemsCell *cell = [OSSVMysCouponItemsCell myCouponsCellWithTableView:tableView andIndexPath:indexPath];
            cell.model = self.available[indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        default:
        {
            OSSVMysCouponItemsCell *cell = [OSSVMysCouponItemsCell myCouponsCellWithTableView:tableView andIndexPath:indexPath];
            cell.model = self.unavailable[indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
    }
}

#pragma mark
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == AvaliableViewTagSpecial) {
        if (self.available.count > indexPath.row) {
            return [OSSVMysCouponItemsCell contentHeigth:self.available[indexPath.row]];
        }
    } else {
        if (self.unavailable.count > indexPath.row) {
            return [OSSVMysCouponItemsCell contentHeigth:self.unavailable[indexPath.row]];
        }
    }
    return [OSSVMysCouponItemsCell contentHeigth:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView.tag == AvaliableViewTagSpecial){
        return 60;
    }
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] init];
    if (tableView.tag == AvaliableViewTagSpecial) {
        OSSVCartSelectCouponVC *controller = (OSSVCartSelectCouponVC *)self.controller;
        [header addSubview: controller.couponApplyView];
    }
    return header;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if (tableView.tag == AvaliableViewTagSpecial) {
        [view.subviews.firstObject mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(12);
            make.trailing.equalTo(-12);
            make.top.mas_equalTo(12);
            make.height.equalTo(48);
        }];

    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == AvaliableViewTagSpecial) {
        
        if (self.available.count > indexPath.row) {
            OSSVMysCouponItemsCell *cell = (OSSVMysCouponItemsCell *)[tableView cellForRowAtIndexPath:indexPath];
            OSSVMyCouponsListsModel *model = cell.model;
            
            if (self.selectedBlock) {
                self.selectedBlock(model);
            }
            
            BOOL flag = model.isSelected;
            model.isSelected = flag;
            cell.model = model;
            
            [self.available enumerateObjectsUsingBlock:^(OSSVMyCouponsListsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.isSelected = NO;
                
                if ([obj.uc_id isEqualToString:model.uc_id]) {
                    obj.isSelected = flag;
                }
                
            }];
            
            [tableView reloadData];
            ///1.4.4 选中后直接使用
            if (self.selectedBlock && flag == YES) {
                self.selectedBlock(model);
            }
        }
    }
}

#pragma mark
#pragma mark - RadioButtonDelegate
-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId {
    OSSVMyCouponsListsModel *model = self.available[index];
    if (self.selectedBlock) {
        self.selectedBlock(model);
    }
}

#pragma mark
#pragma mark - DZNEmptyDataSetSource
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    self.emptyViewManager.customNoDataView = [self makeCustomNoDataView:scrollView];
    return [self.emptyViewManager accordingToTypeReBackView:self.emptyViewShowType];
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView{
    return 0;
}

-(BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return true;
}

#pragma mark
#pragma mark - privateCustomView(NoDataView)
- (UIView *)makeCustomNoDataView:(UIScrollView *)scrollView {
    UIView * customView = [[UIView alloc] initWithFrame:CGRectZero];
    customView.backgroundColor = OSSVThemesColors.col_F6F6F6;
    
    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
    imageView.image = [UIImage imageNamed:@"my_coupon_bank"];
    [customView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        UITableView *table = (UITableView*)scrollView;
        CGFloat topMg = 40;
        if (scrollView.tag == AvaliableViewTagSpecial) {
            topMg = 100;
            if (table.tableHeaderView.bounds.size.height > 10) {
                topMg = 140;
            }
        }
        make.top.mas_equalTo(customView.mas_top).offset(topMg);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = OSSVThemesColors.col_6C6C6C;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = STLLocalizedString_(@"Coupon_NoData_Available_titleLabel", nil);
    titleLabel.text = self.noCouponTitle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [customView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(8);
        make.width.mas_equalTo(SCREEN_WIDTH - 30);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.hidden = true;
    button.backgroundColor = [OSSVThemesColors col_262626];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:STLLocalizedString_(@"refresh", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(emptyOperationTouch) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3;
    [customView addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(33);
        make.centerX.mas_equalTo(customView.mas_centerX);
        make.width.mas_equalTo(@180);
        make.height.mas_equalTo(@40);
    }];
    return customView;
}


@end
