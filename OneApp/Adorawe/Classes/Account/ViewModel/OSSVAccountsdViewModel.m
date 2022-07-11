//
//  OSSVAccountsdViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccountsdViewModel.h"

#import "GBSettingItem.h"
#import "GBSettingArrowItem.h"
#import "GBSettingLabelItem.h"
#import "GBSettingGroup.h"
#import "GBSettingCell.h"

#import "OSSVWMCouponVC.h"
#import "OSSVAccountsMyOrderVC.h"
#import "OSSVWishListVC.h"
#import "OSSVAddressBooksVC.h"
#import "OSSVSettinsgsVC.h"
#import "OSSVMyHelpVC.h"
#import "OSSVFeedbackVC.h"
#import "STLActivityWWebCtrl.h"
#import "OSSVMyGoodReviewsVC.h"
#import "OSSVMessageVC.h"
#import "OSSVNSStringTool.h"
#import "OSSVConfigDomainsManager.h"
#import "OSSVMessageListAip.h"

@interface OSSVAccountsdViewModel ()

@property (nonatomic,strong) NSMutableArray *dataArray;
/** 优惠券 */
@property (nonatomic, strong) GBSettingItem *couponView;
/** 消息 */
@property (nonatomic, strong) GBSettingItem *messageView;

@end

@implementation OSSVAccountsdViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupGroupOneSection];
        [self setupGroupTwoSection];
        [self setupGroupThreeSection];
    }
    return self;
}

#pragma mark - Requset
- (void)messageRequest:(id)parmaters
            completion:(void (^)(id))completion
               failure:(void (^)(id))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVMessageListAip *api = [[OSSVMessageListAip alloc] init];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            OSSVMessageListModel *messageModel = [self dataAnalysisFromJson: requestJSON request:api];
            self.messageView.badgeBlock = ^int{
                return [messageModel.total_count intValue];
            };
            if (completion)
            {
                completion(messageModel);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure)
            {
                failure(nil);
            }
        }];
    } exception:^{
        if (failure)
        {
           failure(nil);
        }
    }];
}


- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[OSSVMessageListAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVMessageListModel yy_modelWithJSON:json[kResult]];
        }
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    GBSettingGroup *group = self.dataArray[section];
    return group.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    GBSettingCell *cell = [GBSettingCell cellWithTableView:tableView];
    GBSettingGroup *group = self.dataArray[indexPath.section];
    cell.item = group.items[indexPath.row];
    cell.lastRowInSection =  (group.items.count - 1 == indexPath.row);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 1.取消选中这行
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GBSettingGroup *group = self.dataArray[indexPath.section];
    GBSettingItem *item = group.items[indexPath.row];
    
    if (item.option) { // block有值(点击这个cell,.有特定的操作需要执行)
        item.option();
        
    } else if ([item isKindOfClass:[GBSettingArrowItem class]]) { // 箭头
        GBSettingArrowItem *arrowItem = (GBSettingArrowItem *)item;

        if (arrowItem.destVcClass == nil)  return;

        UIViewController *vc = [[arrowItem.destVcClass alloc] init];
        vc.title = arrowItem.title;
        [self.controller.navigationController pushViewController:vc  animated:YES];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    GBSettingGroup *group = self.dataArray[section];
    return group.header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    GBSettingGroup *group = self.dataArray[section];
    return group.footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 分割线补全
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (void)updateCouponCount:(NSInteger)count {
    
    self.couponView.badgeBlock = ^int{
        return (int)count;
    };
}

#pragma mark - LoadData
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)setupGroupOneSection {
    
    self.couponView = [GBSettingArrowItem itemWithIcon:@"MyCoupons"
                                                       title:STLLocalizedString_(@"myCoupons",nil)
                                                    subtitle:nil
                                                 destVcClass:[OSSVWMCouponVC class]];
    
    GBSettingItem *orders = [GBSettingArrowItem itemWithIcon:@"list"
                                                       title:STLLocalizedString_(@"myOrder", nil)
                                                    subtitle:nil
                                                 destVcClass:[OSSVAccountsMyOrderVC class]];
    
    GBSettingItem *goodsReview = [GBSettingArrowItem itemWithIcon:@"account_appraise"
                                                       title:STLLocalizedString_(@"My_Reviews", nil)
                                                    subtitle:nil
                                                 destVcClass:[OSSVMyGoodReviewsVC class]];
    
    self.messageView = [GBSettingArrowItem itemWithIcon:@"account_message"
                                                            title:STLLocalizedString_(@"Message", nil)
                                                         subtitle:nil
                                                      destVcClass:[OSSVMessageVC class]];
    
    GBSettingItem *wish  = [GBSettingArrowItem itemWithIcon:@"wish"
                                                      title:STLLocalizedString_(@"My_WishList", nil)
                                                   subtitle:nil
                                                destVcClass:[OSSVWishListVC class]];
    
    GBSettingItem *address = [GBSettingArrowItem itemWithIcon:@"addressbook"
                                                        title:STLLocalizedString_(@"AddressBook", nil)
                                                     subtitle:nil
                                                  destVcClass:[OSSVAddressBooksVC class]];
    
    GBSettingGroup *group = [[GBSettingGroup alloc] init];
    
    group.items = @[self.couponView,orders,goodsReview,self.messageView, wish, address];
    [self.dataArray addObject:group];
}

- (void)setupGroupTwoSection {
    
//    GBSettingItem *support = [GBSettingArrowItem itemWithIcon:@"supportcenter_icon"
//                                                        title:STLLocalizedString_(@"supportCenter", nil)
//                                                     subtitle:STLLocalizedString_(@"supportSubtitle", nil)
//                                                  destVcClass:nil];
//    NSString *appH5Url = [[OSSVConfigDomainsManager sharedInstance] appH5Url];
//    support.option = ^{
//        STLActivityWWebCtrl *webViewController = [STLActivityWWebCtrl new];
//        NSString *webUrl = [NSString stringWithFormat:@"%@%@", appH5Url, STLLocalizedString_(@"articles_supportCenter", nil)];
//        webViewController.strUrl = webUrl;
//        [self.controller.navigationController pushViewController:webViewController animated:YES];
//    };
    
    
    GBSettingItem *feedback = [GBSettingArrowItem itemWithIcon:@"feedback"
                                                         title:STLLocalizedString_(@"FeedBack", nil)
                                                      subtitle:STLLocalizedString_(@"feedbackSubtitle", nil)
                                                   destVcClass:[OSSVFeedbackVC class]];
    
    GBSettingGroup *group = [[GBSettingGroup alloc] init];
    
    group.items = @[feedback];
    [self.dataArray addObject:group];
}

- (void)setupGroupThreeSection {
    
    GBSettingItem *setting = [GBSettingArrowItem itemWithIcon:@"settings"
                                                        title:STLLocalizedString_(@"Settings", nil)
                                                     subtitle:nil
                                                  destVcClass:[OSSVSettinsgsVC class]];
    
    GBSettingItem *help = [GBSettingArrowItem itemWithIcon:@"help"
                                                     title:STLLocalizedString_(@"Help", nil)
                                                  subtitle:nil
                                               destVcClass:[OSSVMyHelpVC class]];
    GBSettingGroup *group = [[GBSettingGroup alloc] init];
    group.items = @[setting,help];
    [self.dataArray addObject:group];
}

@end
