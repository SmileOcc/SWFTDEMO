//
//  ContactsViewModel.m
//  ZZZZZ
//
//  Created by YW on 17/1/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ContactsViewModel.h"
#import "PPGetAddressBook.h"
#import "ZFCommunityContactsCell.h"
#import "ZFLocalizationString.h"
#import "YSAlertView.h"
#import "Constants.h"

@interface ContactsViewModel ()<UIAlertViewDelegate>

@property (nonatomic,strong) NSDictionary *contactPeopleDict;
@property (nonatomic,strong) NSArray *keys;
@property (nonatomic,strong) NSMutableArray *selectArray;
@end

@implementation ContactsViewModel

- (void)loadContactsDataCompletion:(void (^)(NSArray *keys))completion  {
    
    //获取按联系人姓名首字拼音A~Z排序(已经对姓名的第二个字做了处理)
    [PPGetAddressBook getOrderAddressBook:^(NSDictionary<NSString *,NSArray *> *addressBookDict, NSArray *nameKeys) {
        
        //[indicator stopAnimating];
        //装着所有联系人的字典
        self.contactPeopleDict = addressBookDict;
        //联系人分组按拼音分组的Key值
        self.keys = nameKeys;
        if (completion) {
            completion(self.keys);
        }
        
    } authorizationFailure:^{
        
        NSString *title = @"AlertView";
        NSString *message = ZFLocalizedString(@"ContactsViewModel_AuthorizationFailure_Message",nil);
        NSString *cancelTitle = ZFLocalizedString(@"ContactsViewModel_AuthorizationFailure__OK",nil);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ShowAlertView(title, message, @[cancelTitle], ^(NSInteger buttonIndex, id buttonTitle) {
                
                NSURL *urlSetting = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if (urlSetting) {
                    if ([[UIApplication sharedApplication] canOpenURL:urlSetting]) {
                        [[UIApplication sharedApplication] openURL:urlSetting];
                    }
                }
                [self.controller.navigationController popViewControllerAnimated:YES];
                
            }, nil, nil);
        });
    }];
}

#pragma mark - TableViewDatasouce/TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = _keys[section];
    return [_contactPeopleDict[key] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _keys[section];
}

//右侧的索引
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _keys;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = _keys[indexPath.section];
    PPPersonModel *people = [_contactPeopleDict[key] objectAtIndex:indexPath.row];
    ZFCommunityContactsCell *cell = [ZFCommunityContactsCell contactsCellWithTableView:tableView andIndexPath:indexPath];
    cell.model = people;
    @weakify(self)
    cell.contactsSelectBlock = ^(PPPersonModel *model){
        @strongify(self)
        if (model.isSelect) {
            [self.selectArray addObject:model];
        }else{
            [self.selectArray removeObject:model];
        }

        if (self.countBlock) {
            self.countBlock([self.selectArray copy]);
        }
    };
    
    return cell;
}


#pragma mark - Lazyload
-(NSMutableArray *)selectArray {
    if (!_selectArray) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}

@end
