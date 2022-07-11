//
//  OSSVAddresesOfOrdereEnterViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAddresesOfOrdereEnterViewModel.h"
#import "OSSVAddresseBookeAip.h"
#import "OSSVAddresseBookeTableCell.h"

#import "OSSVAddresseBookeModel.h"
#import "OSSVModifyeAddresseViewModel.h"
#import "OSSVDeleteeAdresseAlterView.h"

#import "OSSVAddresseDeleteeAip.h"

#import "Adorawe-Swift.h"

@interface OSSVAddresesOfOrdereEnterViewModel ()<AddressBookTableCellDelegate, STLDeleteAdressAlterViewDelegate>

@property (nonatomic, strong) NSMutableArray           *dataArray;
@property (nonatomic, strong) NSIndexPath              *lastSelected;//上一次选中的额索引
@property (nonatomic, strong) OSSVModifyeAddresseViewModel   *modifyAddressModel;
@property (nonatomic, strong) OSSVAddresseBookeModel        *tempDeleteAddressModel;
@property (nonatomic, strong) OSSVDeleteeAdresseAlterView *popAlterView;

@end

@implementation OSSVAddresesOfOrdereEnterViewModel

- (OSSVModifyeAddresseViewModel *)modifyAddressModel {
    if (!_modifyAddressModel) {
        _modifyAddressModel = [[OSSVModifyeAddresseViewModel alloc]init];
        _modifyAddressModel.controller = self.controller;
    }
    return _modifyAddressModel;
}
#pragma mark ----删除地址
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



#pragma mark - Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {

    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVAddresseBookeAip *adresseBookeAip = [[OSSVAddresseBookeAip alloc] init];
        [adresseBookeAip  startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
//            self.dataArray = [self dataAnalysisFromJson:request.responseJSONObject request:OSSVAddresseBookeAip];
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            self.dataArray = [self dataAnalysisFromJson: requestJSON request:adresseBookeAip];
            if (completion) {
                completion(self.dataArray);
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


#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OSSVAddresseBookeTableCell *cell = [OSSVAddresseBookeTableCell addressBookCellWithTableView:tableView andIndexPath:indexPath];
    cell.delegate = self;
    OSSVAddresseBookeModel *addressModel= self.dataArray[indexPath.row];
    BOOL isSelected = [addressModel.addressId isEqualToString:self.selectedAddressId];
    [cell handleAddressBookModel:addressModel editState:self.editOrRebackType == AddressEidtType ? YES : NO isMark:isSelected isFromOrder:YES];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (self.editOrRebackType) {
        case AddressEidtType:{
        }
            break;
        case AddressRebackType:{
            // 此处为选择Order 之后直接返回
            if (self.getDefalutModelBlock) {
                OSSVAddresseBookeModel *model = self.dataArray[indexPath.row];
                self.getDefalutModelBlock(model);
            }
            [self.controller.navigationController popViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - AddressBookTableCellDelegate

- (void)yyAddressBookTableCell:(OSSVAddresseBookeTableCell *)addressCell addressEvent:(AddressBookEvent)event {
    
    if (event == AddressBookEventDefault) {
        
#pragma mark  修改
        OSSVAddresseBookeModel *addressModel = addressCell.addressBookModel;
//        if (addressModel.isDefault) {
//            return;
//        }
        addressModel.isDefault = !addressModel.isDefault;
        @weakify(self)
        [self.modifyAddressModel requestEditAddressNetwork:addressModel completion:^(id obj) {
            //更新回调刷新AddressList
            @strongify(self)
            if (self.defaultBlock) {
                self.defaultBlock();
            }
            
        } failure:^(id obj) {
            //提示用户更新失败
            STLLog(@"%@", obj);
        }];
        
    } else if(event == AddressBookEventEdit) {
        
        #pragma mark  编辑
        OSSVEditAddressVC *modifyAddressVC = [[OSSVEditAddressVC alloc]init];
        modifyAddressVC.saveBtnTitle = APP_TYPE == 3 ? STLLocalizedString_(@"SaveNContinue", nil) : STLLocalizedString_(@"SaveNContinue", nil).uppercaseString;
        modifyAddressVC.model = addressCell.addressBookModel;
        modifyAddressVC.isModify = @(YES);
        modifyAddressVC.needPopToLastBefore = @(YES);
        //数据更新成功后刷新AddressList
        @weakify(self)
        modifyAddressVC.successBlock = ^(NSString *addressID) {
            @strongify(self)
            ///1.4.2 编辑后直接返回
            if (self.getDefalutModelBlock) {
                self.getDefalutModelBlock(addressCell.addressBookModel);
            }
//            [self.controller.navigationController popViewControllerAnimated:YES];
        };
        modifyAddressVC.getAddressModelBlock = ^(OSSVAddresseBookeModel *model){
            if (self.getModifyAddressModelBlock) {
                self.getModifyAddressModelBlock(model);
            }
        };
        [self.controller.navigationController pushViewController:modifyAddressVC animated:YES];
    } else if (event == AddressBookEventDelete) {
        self.tempDeleteAddressModel = addressCell.addressBookModel;
        self.popAlterView = [[OSSVDeleteeAdresseAlterView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.popAlterView.delegate = self;
        [self.popAlterView showView];
        
    }
}

#pragma mark ---确认删除代理方法
- (void)makeSureAction {
    [self deleteAddressAction];

    [self.popAlterView hiddenView];
}
- (void)deleteAddressAction {
    
    @weakify(self)
    [self requestAddressDeleteNetwork:self.tempDeleteAddressModel.addressId completion:^(id obj){
        @strongify(self)
        if (obj) {
            [self.dataArray removeObject:self.tempDeleteAddressModel];
            //当删除的地址ID 和 下单页地址ID相同时候，发送通知去更新下单接口
            if ([STLToString(self.selectedAddressId) isEqualToString:STLToString(self.tempDeleteAddressModel.addressId)]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_updateCheckOrder object:nil];
            }
            if (self.completeExecuteBlock) {
                self.completeExecuteBlock();
            }
        }
    } failure:^(id obj){
        
    }];
}


@end
