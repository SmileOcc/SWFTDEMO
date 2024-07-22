//
//  ZFOrderQuestionViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/3/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderQuestionViewController.h"
#import "ZFOrderQuestionItemCell.h"
#import "PlacehoderTextView.h"
#import "NSString+Extended.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "ZFLocalizationString.h"
#import "YSAlertView.h"
#import "ZFPopCustomerView.h"
#import "Constants.h"
#import "ZFRequestModel.h"
#import "ZFApiDefiner.h"
#import "YWLocalHostManager.h"
#import "YWCFunctionTool.h"
#import "ZFProgressHUD.h"
#import "ZFMyOrderListViewController.h"
#import "ZFOrderDetailViewController.h"
#import "SystemConfigUtils.h"
#import "ZFOrderDetailViewModel.h"
#import "ZFCartViewController.h"
#import <Masonry/Masonry.h>
#import "YSTextView.h"

@interface ZFOrderQuestionViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    UITextViewDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *commitButton;
@property (nonatomic, strong) YSTextView *tableTextView;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSMutableArray *questionList;
@property (nonatomic, strong) NSMutableArray *selectItems;
@property (nonatomic, strong) ZFPopCustomerView *popCustomerView;
@property (nonatomic, strong) ZFOrderDetailViewModel *viewModel;
@end

@implementation ZFOrderQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"QuestionVC_Title", nil);
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

-(void)goBackAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOrderQuestionViewControllerDidClickBackToOrders)]) {
        [self.delegate ZFOrderQuestionViewControllerDidClickBackToOrders];
    }
    if (self.didClickbackToOrdersBlockHandle) {
        self.didClickbackToOrdersBlockHandle();
    }
}

#pragma mrak - dataSource delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.questionList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFOrderQuestionItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[ZFOrderQuestionItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    ZFOrderQuestionModel *currentModel = self.questionList[indexPath.row];
    if (self.currentIndexPath == indexPath) {
        currentModel.isSelect = YES;
    } else {
        currentModel.isSelect = NO;
    }
    cell.model = currentModel;
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UITableViewHeaderFooterView *headerFootView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
        if (!headerFootView) {
            headerFootView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"Header"];
            
            UILabel *textLabel = [[UILabel alloc] init];
            textLabel.numberOfLines = 0;
            textLabel.text = ZFLocalizedString(@"Question_Title", nil);
            textLabel.font = [UIFont boldSystemFontOfSize:17];
            [headerFootView addSubview:textLabel];
            
            [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(headerFootView.mas_leading).mas_offset(15);
                make.trailing.mas_equalTo(headerFootView.mas_trailing).mas_offset(-15);
                make.top.mas_equalTo(headerFootView).mas_offset(24);
                make.bottom.mas_equalTo(headerFootView.mas_bottom).mas_offset(-12);
            }];
        }
        return headerFootView;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentIndexPath == indexPath) {
        return;
    }
    self.currentIndexPath = indexPath;
//    if (self.currentIndexPath.row == self.questionList.count - 1) {
//        //最后一个是输入用户自己的想法,需要判断里面的输入字数
//        if (!self.tableTextView.text.length) {
//            ShowToastToViewWithText(nil, ZFLocalizedString(@"Question_Tips", nil));
//        }
//    }
    [self exChangeCommitButtonStatus:YES];
//    }
    [tableView reloadData];
    
    [self.tableTextView resignFirstResponder];
    NSString *placeHold = ZFLocalizedString(@"Question_WriteSome", nil);
    if (indexPath.row == 4) {
        //请填写您需要的支付方式或支付过程中的问题
        [self.tableTextView becomeFirstResponder];
        placeHold = ZFLocalizedString(@"Question_inputPayment", nil);
    } else if (indexPath.row == 2) {
        //请说明您想要修改的订单内容
        [self.tableTextView becomeFirstResponder];
        placeHold = ZFLocalizedString(@"Question_inputOrderChange", nil);
    }
    self.tableTextView.placeholder = placeHold;
    
//    ZFOrderQuestionModel *currentModel = self.questionList[indexPath.row];
//    currentModel.isSelect = !currentModel.isSelect;
//    ZFOrderQuestionItemCell *cell = (ZFOrderQuestionItemCell *)[tableView cellForRowAtIndexPath:indexPath];
//    cell.model = currentModel;
//
//    __block BOOL haveSelect = NO;
//    [self.questionList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        ZFOrderQuestionModel *model = (ZFOrderQuestionModel *)obj;
//        if (model.isSelect) {
//            haveSelect = YES;
//            *stop = YES;
//        }
//    }];
//
//    if (haveSelect) {
//        if (indexPath.row == self.questionList.count - 1 && currentModel.isSelect) {
//            //最后一个是输入用户自己的想法,需要判断里面的输入字数
//            if (self.tableTextView.text.length) {
//                [self exChangeCommitButtonStatus:YES];
//            } else {
//                [self exChangeCommitButtonStatus:NO];
//            }
//        }else {
//            [self exChangeCommitButtonStatus:YES];
//        }
//    } else {
//        [self exChangeCommitButtonStatus:NO];
//    }
}

#pragma mark - textView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length > 200) {
        return NO;
    }
    if (textView.text.length > 0) {
        [self exChangeCommitButtonStatus:YES];
    }
    return YES;
}

#pragma mark - private method

- (void)exChangeCommitButtonStatus:(BOOL)enabled
{
    if (enabled) {
        self.commitButton.backgroundColor = ZFC0x2D2D2D();
    } else {
        self.commitButton.backgroundColor = ZFC0xCCCCCC();
    }
}

#pragma mark - network

- (void)requestOrderBackToCartWithOrderId:(NSString *)orderId {
    @weakify(self);
    NSDictionary *dict = @{
                           @"order_id" : orderId,
                           @"force_add" : @"1",
                           kLoadingView : self.view
                           };
    [self.viewModel requestReturnToBag:dict completion:^(id obj) {
        @strongify(self);
        ZFNavigationController *accountNavVC = [self queryTargetNavigationController:TabBarIndexHome];
        ZFCartViewController *cartVC = [[ZFCartViewController alloc] init];
        [self.navigationController popToRootViewControllerAnimated:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            ShowToastToViewWithText(nil, ZFLocalizedString(@"OrderDetail_OneKeyAddSuccessTips", nil));
            [accountNavVC pushViewController:cartVC animated:NO];
        });
    } failure:^(id obj) {
        //do nothing
        @strongify(self);
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"Failed", nil));
    }];
}


#pragma mark - target method

- (void)commitBtnAction
{
    if (!self.currentIndexPath) {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"Question_Tips", nil));
        return;
    }
    ZFOrderQuestionModel *lastModel = [self.questionList lastObject];
    NSString *tipsMsg = nil;
    if (lastModel.isSelect) {
        if (!self.tableTextView.text.length) {
            tipsMsg = ZFLocalizedString(@"Question_TipsSpecify", nil);
        }
    }
    ZFOrderQuestionModel *noPaymentModel = self.questionList[4];
    if (noPaymentModel.isSelect) {
        if (!self.tableTextView.text.length) {
            tipsMsg = ZFLocalizedString(@"Question_inputPayment", nil);
        }
    }
    ZFOrderQuestionModel *changeOrderModel = self.questionList[2];
    if (changeOrderModel.isSelect) {
        if (!self.tableTextView.text.length) {
            tipsMsg = ZFLocalizedString(@"Question_inputOrderChange", nil);
        }
    }
    
    if (tipsMsg) {
        ShowToastToViewWithText(nil, tipsMsg);
        return;
    }
    
    [self commitRequest];
}

- (void)commitRequest
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(@"order/collect_no_payment_info");
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:USERID forKey:@"user_id"];
    
    ZFOrderQuestionModel *currentModel = self.questionList[self.currentIndexPath.row];
    NSMutableArray *selectItems = [[NSMutableArray alloc] init];
    NSDictionary *currentParams = @{
                              @"id" : currentModel.contentId,
                              @"content" : currentModel.content
                              };
    [selectItems addObject:currentParams];

    [params setObject:selectItems forKey:@"no_payment_type"];
    [params setObject:ZFToString(self.ordersn) forKey:@"order_sn"];
    [params setObject:ZFToString(self.tableTextView.text) forKey:@"no_payment_info"];
    
    requestModel.parmaters = @{
                               @"survey" : @[params],
                               };
    ShowLoadingToView(self.view);
    @weakify(self)
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        @strongify(self)
        HideLoadingFromView(self.view);
        NSInteger statusCode = [responseObject[@"statusCode"] integerValue];
        if (statusCode == 200) {
            if (currentModel.contentId.integerValue == 4) {
                //用户想要修改地址，直接跳到订单详情修改地址页面
                [self jumpToOrderDetailChangeAddressPage];
                return;
            }
            if (currentModel.contentId.integerValue == 3) {
                //一键加购所有商品并回到购物车
                [self jumpToCart];
                return;
            }
            [self showPopView];
        } else {
            ShowErrorToastToViewWithResult(self.view, responseObject);
        }
    } failure:^(NSError *error) {
        YWLog(@"%@", error);
        ShowToastToViewWithText(nil, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
    }];
}

#pragma mark - private method

- (void)showPopView
{
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    CustomerImageModel *cellModel = [[CustomerImageModel alloc] init];
    cellModel.imagePath = @"questionTopIcon";
    [dataSource addObject:cellModel];
    
    CustomerTitleModel *cellModel1 = [[CustomerTitleModel alloc] init];
    cellModel1.content = ZFLocalizedString(@"Question_Thank", nil);
    cellModel1.edgeInsets = UIEdgeInsetsMake(16, 0, 0, 0);
    cellModel1.contentTextAlignment = NSTextAlignmentCenter;
    [dataSource addObject:cellModel1];
    
    CustomerTitleModel *cellModel2 = [[CustomerTitleModel alloc] init];
    cellModel2.content = ZFLocalizedString(@"Question_GreatGoods", nil);
    cellModel2.edgeInsets = UIEdgeInsetsMake(6, 0, 0, 0);
    cellModel1.contentTextAlignment = NSTextAlignmentCenter;
    [dataSource addObject:cellModel2];
    
    CustomerCountDownButtonModel *cellModel4 = [[CustomerCountDownButtonModel alloc] init];
    cellModel4.buttonTitle = [ZFLocalizedString(@"Question_backOrders", nil) uppercaseString];
    cellModel4.buttonBackgroundColor = ZFC0xFE5269();
    cellModel4.titleColor = [UIColor whiteColor];
    cellModel4.countDown = 10;
    cellModel4.edgeInsets = UIEdgeInsetsMake(36, 0, 0, 0);
    @weakify(self)
    cellModel4.didClickItemBlock = ^{
        //选择了按钮, 订单详情页
        @strongify(self)
        [self.popCustomerView hiddenCustomer];
        if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOrderQuestionViewControllerDidClickBackToOrders)]) {
            [self.delegate ZFOrderQuestionViewControllerDidClickBackToOrders];
        }
        if (self.didClickbackToOrdersBlockHandle) {
            self.didClickbackToOrdersBlockHandle();
        }
    };
    [dataSource addObject:cellModel4];
    
    CustomerButtonModel *cellModel5 = [[CustomerButtonModel alloc] init];
    cellModel5.buttonTitle = ZFLocalizedString(@"homeButton", nil);
    cellModel5.buttonBackgroundColor = [UIColor whiteColor];
    cellModel5.titleColor = ZFC0x999999();
    cellModel5.edgeInsets = UIEdgeInsetsMake(0, 0, 5, 0);
    cellModel5.didClickItemBlock = ^{
        //选择了按钮, 回到首页
        @strongify(self)
        [self.popCustomerView hiddenCustomer];
        if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOrderQuestionViewControllerDidClickGontinueShopping)]) {
            [self.delegate ZFOrderQuestionViewControllerDidClickGontinueShopping];
        }
        if (self.didClickGoShoppingHandle) {
            self.didClickGoShoppingHandle();
        }
    };
    [dataSource addObject:cellModel5];
    
    [self.popCustomerView showCustomer:[dataSource copy]];
}

- (ZFNavigationController *)queryTargetNavigationController:(NSInteger)index {
    ZFTabBarController *tabBarVC = APPDELEGATE.tabBarVC;
    [tabBarVC setZFTabBarIndex:index];
    ZFNavigationController *targetNavVC = (ZFNavigationController *)tabBarVC.viewControllers[tabBarVC.selectedIndex];
    return targetNavVC;
}

//跳转到订单详情的修改地址页
- (void)jumpToOrderDetailChangeAddressPage
{
    ZFOrderDetailViewController *orderDetailVC = [self jumpToOrderDetail];
    [orderDetailVC requestChangeAddress:self.ordersn];
}

//跳转到订单详情页
- (ZFOrderDetailViewController *)jumpToOrderDetail
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    ZFNavigationController *navi = [self queryTargetNavigationController:TabBarIndexAccount];
    ZFMyOrderListViewController *orderListVC = [[ZFMyOrderListViewController alloc] init];
    [navi pushViewController:orderListVC animated:NO];
    
    ZFOrderDetailViewController *orderDetailVC = [[ZFOrderDetailViewController alloc] init];
    orderDetailVC.orderId = self.orderId;
    orderDetailVC.addressNoPayOrder = YES;
    [orderListVC.navigationController pushViewController:orderDetailVC animated:NO];
    return orderDetailVC;
}

//加购所有订单商品并跳转到首页购物车页面
- (void)jumpToCart
{
    NSString *message = ZFLocalizedString(@"OrderDetail_OneKeyAddPdTips", nil);
    NSString *confirm = ZFLocalizedString(@"OrderDetail_AddAllItems", nil);
    NSString *cancel = ZFLocalizedString(@"Cancel", nil);
    @weakify(self)
    ShowVerticalAlertView(nil, message, @[cancel], ^(NSInteger buttonIndex, id buttonTitle) {
        @strongify(self)
        [self jumpToOrderDetail];
    }, confirm, ^(id cancelTitle) {
        @strongify(self)
        [self requestOrderBackToCartWithOrderId:self.orderId];
    });
}

#pragma mrak - Property

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.backgroundColor = [UIColor whiteColor];
            tableView.showsHorizontalScrollIndicator = NO;
            tableView.showsVerticalScrollIndicator = YES;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.rowHeight = UITableViewAutomaticDimension;
            tableView.estimatedRowHeight = 112;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension;
            tableView.tableFooterView = ({
                CGFloat width = self.view.frame.size.width;
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 120 + 40 + 24)];
                view.backgroundColor = [UIColor whiteColor];
                [view addSubview:self.tableTextView];
                
                UIButton *commitBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.tableTextView.frame) + 24, width - 30, 40)];
                commitBtn.backgroundColor = ZFC0xCCCCCC();
                commitBtn.layer.cornerRadius = 3;
                commitBtn.layer.masksToBounds = YES;
                commitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
                [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [commitBtn setTitle:ZFLocalizedString(@"submit", nil) forState:UIControlStateNormal];
                [commitBtn addTarget:self action:@selector(commitBtnAction) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:commitBtn];
                self.commitButton = commitBtn;
                view;
            });
            tableView.tableHeaderView = ({
                CGFloat width = self.view.frame.size.width;
                NSString *text = ZFLocalizedString(@"Question_TitleHeader", nil);
                UIFont *font = [UIFont systemFontOfSize:12];
                CGFloat height = [text textSizeWithFont:font constrainedToSize:CGSizeMake(width - 32, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height + 12)];
                view.backgroundColor = ZFC0xF2F2F2();
                UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 6, width - 32, height)];
                textLabel.text = text;
                textLabel.numberOfLines = 0;
                textLabel.textColor = ZFC0x999999();
                textLabel.font = font;
                [view addSubview:textLabel];
                view;
            });
            tableView;
        });
    }
    return _tableView;
}

-(YSTextView *)tableTextView
{
    if (!_tableTextView) {
        _tableTextView = ({
            YSTextView *textView = [[YSTextView alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 80)];
            textView.placeholder = ZFLocalizedString(@"Question_WriteSome", nil);
            textView.placeholderPoint = CGPointMake(7, 7);
            textView.layer.borderWidth = 1;
            textView.layer.borderColor = ZFC0xDDDDDD().CGColor;
            textView.delegate = self;
            if ([SystemConfigUtils isRightToLeftShow]) {
                textView.textAlignment = NSTextAlignmentRight;
            } else {
                textView.textAlignment = NSTextAlignmentLeft;
            }
            textView;
        });
    }
    return _tableTextView;
}

-(NSMutableArray *)questionList
{
    if (!_questionList) {
        _questionList = [[NSMutableArray alloc] init];

        NSArray *content = @[
                             ZFLocalizedString(@"Question_One", nil),
                             ZFLocalizedString(@"Question_Two", nil),
                             ZFLocalizedString(@"Question_Three", nil),
                             ZFLocalizedString(@"Question_Four", nil),
                             ZFLocalizedString(@"Question_Five", nil),
                             ZFLocalizedString(@"Question_Six", nil),
                             ZFLocalizedString(@"Question_Seven", nil),
                             ZFLocalizedString(@"Question_Eight", nil),
                             ZFLocalizedString(@"Question_Nine", nil),
                             ];
        
        NSInteger count = content.count;
        for (int i = 0; i < count; i++) {
            ZFOrderQuestionModel *model = [[ZFOrderQuestionModel alloc] init];
            model.content = (NSString *)content[i];
            model.contentId = [NSString stringWithFormat:@"%d", i + 1];
            [_questionList addObject:model];
        }
    }
    return _questionList;
}

- (ZFPopCustomerView *)popCustomerView
{
    if (!_popCustomerView) {
        _popCustomerView = [[ZFPopCustomerView alloc] init];
    }
    return _popCustomerView;
}

- (ZFOrderDetailViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFOrderDetailViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

@end
