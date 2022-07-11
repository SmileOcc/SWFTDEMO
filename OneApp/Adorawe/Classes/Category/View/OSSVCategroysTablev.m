//
//  OSSVCategroysTablev.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategroysTablev.h"
#import "OSSVCategorysTableCell.h"

@interface OSSVCategroysTablev()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation OSSVCategroysTablev

#pragma mark - life cycle

+ (CGFloat)contnetCellHeight {
    if (APP_TYPE == 3) {
        return 58;
    }
    return 48;
}
- (instancetype)initWithFrame:(CGRect)frame
                        style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style])
    {
        self.dataSource = self;
        self.delegate = self;
        self.showsVerticalScrollIndicator = NO;
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        [self registerClass:[OSSVCategorysTableCell class] forCellReuseIdentifier:NSStringFromClass(OSSVCategorysTableCell.class)];
    }
    return self;
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVCategorysTableCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVCategorysTableCell.class) forIndexPath:indexPath];
        
    NSArray *tempdatas = self.dataArray;
    if (tempdatas.count > indexPath.row) {
        
        OSSVCategorysModel *model = tempdatas[indexPath.row];
        model.cornersIndex = 0;
        
        if (self.selectIndexPath.row == 0 || !self.selectIndexPath) {
            //第一个cell 只切右下角
            if (indexPath.row == 1) {
                model.cornersIndex = 2;
            }
            
        } else if(self.selectIndexPath.row == tempdatas.count - 1) { //选中的上一个cell
            if (indexPath.row == tempdatas.count - 2) {
                model.cornersIndex = 4;
            }
            
        } else {
            
            if (indexPath.row == self.selectIndexPath.row - 1) {
                model.cornersIndex = 4;
            } else if (indexPath.row == self.selectIndexPath.row + 1) {
                model.cornersIndex = 2;
                
            }
        }
        cell.categoryModel = tempdatas[indexPath.row];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [OSSVCategroysTablev contnetCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVCategorysTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectIndexPath = indexPath;
    if (indexPath.row == 0) {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    } else {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }

    [cell routerWithEventName:@"CategoriesSelectedCell" userInfo:@{@"selectIdx" : @(indexPath.row)}];
    
    NSArray *tempdatas = self.dataArray;
    if(tempdatas.count > indexPath.row) {
        
        OSSVCategorysModel *currentModel = tempdatas[indexPath.row];
        [tempdatas enumerateObjectsUsingBlock:^(OSSVCategorysModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([currentModel.cat_id isEqualToString:obj.cat_id]) {
                obj.isSelected = YES;
            } else {
                obj.isSelected = NO;
            }
        }];
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(didDeselectRowAtIndexPath:)]) {
            [self.myDelegate didDeselectRowAtIndexPath:indexPath];
        }
        
        [tableView reloadData];
        
        ///1.3.8 埋点
        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        NSString *attrNode3 = [NSString stringWithFormat:@"custom_first_categories_%@",currentModel.title];
        NSDictionary *sensorsDicClick = @{@"page_name":STLToString(pageName),
                                          @"attr_node_1":@"home_tab",
                                          @"attr_node_2":@"home_category",
                                          @"attr_node_3":attrNode3,
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDicClick];
        
        //数据GA埋点曝光 广告点击
                            
                            // item
                            NSMutableDictionary *item = [@{
                        //          kFIRParameterItemID: $itemId,
                        //          kFIRParameterItemName: $itemName,
                        //          kFIRParameterItemCategory: $itemCategory,
                        //          kFIRParameterItemVariant: $itemVariant,
                        //          kFIRParameterItemBrand: $itemBrand,
                        //          kFIRParameterPrice: $price,
                        //          kFIRParameterCurrency: $currency
                            } mutableCopy];


                            // Prepare promotion parameters
                            NSMutableDictionary *promoParams = [@{
                        //          kFIRParameterPromotionID: $promotionId,
                        //          kFIRParameterPromotionName:$promotionName,
                        //          kFIRParameterCreativeName: $creativeName,
                        //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                        //          @"screen_group":@"Home"
                            } mutableCopy];

                            // Add items
                            promoParams[kFIRParameterItems] = @[item];
                            
                        //        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0)
{
//    [tableView cellForRowAtIndexPath:indexPath].backgroundColor = OSSVThemesColors.col_FFFFFF;
}

- (void)updateData:(NSArray *)dataArray {
    
    self.dataArray = dataArray;
    OSSVCategorysModel *currentModel = self.dataArray.firstObject;
    if (currentModel) {
        currentModel.isSelected = YES;
    }
    [self reloadData];
    self.selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self selectRowAtIndexPath:self.selectIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    

}

- (void)updateSelectIndex:(NSInteger)index {
    
    NSArray *tempdatas = self.dataArray;
    for (int i=0; i<tempdatas.count; i++) {
        OSSVCategorysModel *currentModel = tempdatas[i];
        currentModel.isSelected = NO;
        if (i == index) {
            currentModel.isSelected = YES;
        }
    }
    self.selectIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self reloadData];
}

@end
