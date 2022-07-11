//
//  OSSVAddresseBookeViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAddresseBookeViewModel.h"
#import "OSSVAddresseBookeTableCell.h"
#import "OSSVAddresseBookeAip.h"
#import "OSSVAddresseDeleteeAip.h"
#import "OSSVAddresseBookeModel.h"
#import "OSSVModifyeAddresseViewModel.h"
#import "OSSVPersoneCentereAddressCell.h"

#import "OSSVDeleteeAdresseAlterView.h"
#import "Adorawe-Swift.h"


@interface OSSVAddresseBookeViewModel ()<AddressBookTableCellDelegate, STLDeleteAdressAlterViewDelegate>

@property (nonatomic, strong) NSMutableArray          *dataArray;
@property (nonatomic, strong) OSSVAddresseBookeModel        *tempDeleteAddressModel;
@property (nonatomic, strong) OSSVModifyeAddresseViewModel  *modifyAddressModel;
@property (nonatomic, strong) OSSVDeleteeAdresseAlterView *popAlterView;

@end

@implementation OSSVAddresseBookeViewModel

- (OSSVModifyeAddresseViewModel *)modifyAddressModel {
    if (!_modifyAddressModel) {
        _modifyAddressModel = [[OSSVModifyeAddresseViewModel alloc]init];
        _modifyAddressModel.controller = self.controller;
    }
    return _modifyAddressModel;
}

#pragma mark - Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {

    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVAddresseBookeAip *addresBookeAip = [[OSSVAddresseBookeAip alloc] init];
        [addresBookeAip  startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
//            self.dataArray = [self dataAnalysisFromJson:request.responseJSONObject request:OSSVAddresseBookeAip];
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            self.dataArray = [self dataAnalysisFromJson: requestJSON request:addresBookeAip];
            self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoData;
            if (completion) {
                completion(self.dataArray);
            }
    
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            @strongify(self)
            self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoNet;
            if (failure) {
                failure(nil);
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
- (void)requestAddressDeleteNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {

    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        NSString *addressId = (NSString *)parmaters;
        OSSVAddresseDeleteeAip *adresseDeleteeAip = [[OSSVAddresseDeleteeAip alloc] initWithAddressDeleteId:addressId];
        [adresseDeleteeAip startWithBlockSuccess: ^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            BOOL isSucessDelete = NO;
            if ([self dataAnalysisFromJson: requestJSON request:adresseDeleteeAip]) {
                isSucessDelete = YES;
            }
            if (completion) {
                completion(@(isSucessDelete));
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
      
        if (failure) {
            failure(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    
//    STLLog(@"json list === %@",json);
    if ([request isKindOfClass:[OSSVAddresseBookeAip class]]) {
        
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [NSArray yy_modelArrayWithClass:[OSSVAddresseBookeModel class] json:json[kResult]];
        }
        else {
            if ([json[kStatusCode] integerValue] == 201) return nil;
            [self alertMessage:json[@"message"]];
        }
    }
    if ([request isKindOfClass:[OSSVAddresseDeleteeAip class]]) {
        
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            ;
            [self alertMessage:json[@"message"]];
            return @YES;
        }
        else {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}

#pragma mark  - 修改
- (void)updateAddressBookModel:(OSSVAddresseBookeModel *)model {
    
//    if (model.isDefault) {
//        return;
//    }
    
    model.isDefault = !model.isDefault;
    @weakify(self)
    [self.modifyAddressModel requestEditAddressNetwork:model completion:^(id obj) {
        //更新回调刷新AddressList
        @strongify(self)
        if (self.defaultBlock) {
            self.defaultBlock();
        }
        
    } failure:^(id obj) {
        //提示用户更新失败
        STLLog(@"%@", obj);
    }];
}

#pragma mark  编辑

- (void)editAddressBookModel:(OSSVAddresseBookeModel *)model {
    OSSVEditAddressVC *modifyAddressVC = [[OSSVEditAddressVC alloc] init];
    modifyAddressVC.model = model;
    modifyAddressVC.isModify = @(YES);
    //数据更新成功后刷新AddressList
    @weakify(self)
    modifyAddressVC.successBlock = ^(NSString *addressID) {
        @strongify(self)
        if (self.updateBlock) {
            self.updateBlock();
        }
    };
    [self.controller.navigationController pushViewController:modifyAddressVC animated:YES];
}

#pragma mark 删除
- (void)deleteAddressBookModel:(OSSVAddresseBookeModel *)model {
    
    self.tempDeleteAddressModel = model;
    
    self.popAlterView = [[OSSVDeleteeAdresseAlterView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.popAlterView.delegate = self;
    [self.popAlterView showView];
    
    
//    [self makeShowAlertWithDeleteAction];
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVPersoneCentereAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVPersoneCentereAddressCell" forIndexPath:indexPath];
    [cell handleAddressBookModel:self.dataArray[indexPath.row] editState:self.isEdit isMark:NO isFromOrder:NO];
    cell.delegate = self;
    return cell;
}

#pragma mark - AddressBookTableCellDelegate

- (void)yyAddressBookTableCell:(OSSVAddresseBookeTableCell *)addressCell addressEvent:(AddressBookEvent)event {
    
    if (event == AddressBookEventDefault) {
        [self updateAddressBookModel:addressCell.addressBookModel];
        
    } else if(event == AddressBookEventEdit) {
        [self editAddressBookModel:addressCell.addressBookModel];
        
    } else if(event == AddressBookEventDelete){
        [self deleteAddressBookModel:addressCell.addressBookModel];
    }

}


#pragma mark - DeleteAction--------UI样式改变，不用系统弹窗了

- (void)makeShowAlertWithDeleteAction{
    
    STLAlertViewController *alertController =  [STLAlertViewController
                                           alertControllerWithTitle: nil
                                           message:STLLocalizedString_(@"deleteAddress", nil)
                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"no", nil) : STLLocalizedString_(@"no", nil).uppercaseString style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (self.resumeDeleteActionBlock) {
            self.resumeDeleteActionBlock();
        }
    }];
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"yes", nil) : STLLocalizedString_(@"yes", nil).uppercaseString style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self deleteAddressAction];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    [self.controller presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark ---确认删除代理方法
- (void)makeSureAction {
    //GA----点击确认（YES）按钮的统计
    [OSSVAnalyticsTool analyticsGAEventWithName:@"personal_action" parameters:@{@"screen_group" : @" AddressBook",
                                                                           @"action"       : @"Remove Address_Confirm"
    }];
    
    [self deleteAddressAction];
    [self.popAlterView hiddenView];
}
- (void)deleteAddressAction {
    
    @weakify(self)
    [self requestAddressDeleteNetwork:self.tempDeleteAddressModel.addressId completion:^(id obj){
        @strongify(self)
        if (obj) {
            [self.dataArray removeObject:self.tempDeleteAddressModel];
            if (self.completeExecuteBlock) {
                self.completeExecuteBlock();
            }
        }
    } failure:^(id obj){
        
    }];
}

//#pragma mark - DZNEmptyDataSetSource Methods
//- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
//    self.emptyViewManager.customNoDataView = [self makeCustomNoDataView];
//    return [self.emptyViewManager accordingToTypeReBackView:self.emptyViewShowType];
//}
//
//#pragma mark make - privateCustomView(NoDataView)
//- (UIView *)makeCustomNoDataView {
//    UIView * customView = [[UIView alloc] initWithFrame:CGRectZero];
//    customView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
//
//    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
//    imageView.image = [UIImage imageNamed:@"address_bank"];
//    [customView addSubview:imageView];
//
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(customView.mas_top).offset(52 * DSCREEN_HEIGHT_SCALE);
//        make.centerX.mas_equalTo(customView.mas_centerX);
//    }];
//
//    UILabel *titleLabel = [UILabel new];
//    titleLabel.textColor = [UIColor colorWithHexString:@"#6c6c6c"];
//    titleLabel.font = [UIFont systemFontOfSize:14];
//    titleLabel.text = STLLocalizedString_(@"addressBook_blank", nil);
//    titleLabel.numberOfLines = 0;
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    [customView addSubview:titleLabel];
//
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(imageView.mas_bottom).offset(8);
//        make.leading.mas_equalTo(@40);
//        make.trailing.mas_equalTo(@(-40));
//    }];
//
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.backgroundColor = [OSSVThemesColors col_262626];
//    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [button setTitle: STLLocalizedString_(@"addressAddAdress", nil).uppercaseString forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(emptyJumpOperationTouch) forControlEvents:UIControlEventTouchUpInside];
////    button.layer.cornerRadius = 3;
//    [customView addSubview:button];
//
//    [button mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(titleLabel.mas_bottom).offset(16);
//        make.centerX.equalTo(customView.mas_centerX);
//        make.width.mas_equalTo(@185);
//        make.height.mas_equalTo(@36);
//    }];
//
//    return customView;
//}
//
//- (void)emptyDataSetWillAppear:(UIScrollView *)scrollView {
//    scrollView.contentOffset = CGPointZero;
//}

- (void)dealloc {
    STLLog(@"OSSVAddresseBookeViewModel  Dealloc");
}
@end
