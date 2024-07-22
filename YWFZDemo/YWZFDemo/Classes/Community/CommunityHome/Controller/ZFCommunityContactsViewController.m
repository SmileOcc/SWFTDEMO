//
//  ZFCommunityContactsViewController.m
//  ZZZZZ
//
//  Created by YW on 17/1/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityContactsViewController.h"
#import "ContactsViewModel.h"
#import <MessageUI/MessageUI.h>
#import "PPPersonModel.h"
#import "PPAddressBookHandle.h"
#import "ZFCommuntityGestureTableView.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "Constants.h"

#define kPPAddressBookHandle [PPAddressBookHandle sharedAddressBookHandle]

@interface ZFCommunityContactsViewController ()<MFMessageComposeViewControllerDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) UIButton *sendButton;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) ContactsViewModel *viewModel;
@property (nonatomic,strong) NSMutableArray *phoneArray;
@end

@implementation ZFCommunityContactsViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"Contacts_VC_Title",nil);
    [self configureUI];
    
    [kPPAddressBookHandle requestAuthorizationWithSuccessBlock:^{
        
        @weakify(self)
        [self.viewModel loadContactsDataCompletion:^(NSArray *keys) {
            @strongify(self)
            
            if (ZFJudgeNSArray(keys)) {
                self.sendButton.enabled = keys.count;
            }
            [self.tableView reloadData];
            [self.tableView showRequestTip:@{}];
        }];
        
    } failure:^{
        
        NSString *title = ZFLocalizedString(@"ContactsViewModel_AuthorizationFailure_Title",nil);
        NSString *message = ZFLocalizedString(@"ContactsViewModel_AuthorizationFailure_Message",nil);
        NSString *cancelTitle = ZFLocalizedString(@"ContactsViewModel_AuthorizationFailure__OK",nil);
        NSString *otherTitle = ZFLocalizedString(@"ContactsViewModel_AuthorizationFailure__GoToSetting",nil);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ShowAlertView(title, message, @[otherTitle], ^(NSInteger buttonIndex, id buttonTitle) {
                
                NSURL *urlSetting = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if (urlSetting) {
                    if ([[UIApplication sharedApplication] canOpenURL:urlSetting]) {
                        [[UIApplication sharedApplication] openURL:urlSetting options:@{} completionHandler:nil];
                    }
                }
                [self.navigationController popViewControllerAnimated:YES];
                
            }, cancelTitle, ^(id cancelTitle) {
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
    }];
}

#pragma mark - UI
- (void)configureUI {
    [self.view addSubview:self.tableView];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:self.sendButton];
    self.navigationItem.rightBarButtonItem = item;
};

#pragma mark - Button Action
- (void)sendBtnClicked:(UIButton *)sender {
    if (self.phoneArray.count <= 0) {
        return;
    }
    NSString *message = ZFLocalizedString(@"Contacts_VC_Message",nil);
    [self showMessageView:self.phoneArray title:@"Message" body:message];
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)showMessageView:(NSArray *)phones title:(NSString *)title body:(NSString *)body
{
    if([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        // --phones发短信的手机号码的数组，数组中是一个即单发,多个即群发。
        controller.recipients = phones;
        // --短信界面 BarButtonItem (取消按钮) 颜色
        controller.navigationBar.tintColor = [UIColor redColor];
        // --短信内容
        controller.body = body;
        controller.messageComposeDelegate = self;
        controller.title = @"Message";
        
        [self.navigationController presentViewController:controller animated:YES completion:nil];
        
    } else {
        NSString *message = @"Does not support sending text messages";
        ShowAlertSingleBtnView(nil, message, @"OK");
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    controller.recipients = nil;
    controller.body = nil;
    controller.title = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    switch (result) {
        case MessageComposeResultCancelled:
            YWLog(@"取消发送");
            break;
            
        case MessageComposeResultSent:
            YWLog(@"已发送");
            break;
            
        case MessageComposeResultFailed:
            YWLog(@"发送失败");
            break;
            
        default:
            break;
    }
}

#pragma mark - Lazyload
-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64) style:UITableViewStylePlain];
        _tableView.rowHeight = 40;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self.viewModel;
        _tableView.dataSource = self.viewModel;
        _tableView.sectionIndexColor = ZFCOLOR(255, 168, 0, 1);
        _tableView.emptyDataTitle = ZFLocalizedString(@"ContactsVC_HasNoDataTips", nil);
        _tableView.emptyDataImage = ZFImageWithName(@"blankPage_requestFail");
    }
    return _tableView;
}

-(ContactsViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ContactsViewModel alloc] init];
        _viewModel.controller = self;
        @weakify(self)
        _viewModel.countBlock = ^(NSArray *array){
            @strongify(self)
            NSString *countStr;
            if (array.count <= 0) {
                if ([SystemConfigUtils isRightToLeftShow]) {
                    countStr = [NSString stringWithFormat:@"(%ld)%@",(unsigned long)array.count,ZFLocalizedString(@"Contacts_VC_Send",nil)];
                } else {
                    countStr = [NSString stringWithFormat:@"%@(%ld)",ZFLocalizedString(@"Contacts_VC_Send",nil),(unsigned long)array.count];
                }
                
            }else{
                if ([SystemConfigUtils isRightToLeftShow]) {
                    countStr = [NSString stringWithFormat:@"(%ld)%@",(unsigned long)array.count,ZFLocalizedString(@"Contacts_VC_Send",nil)];
                } else {
                    countStr = [NSString stringWithFormat:@"%@(%ld)",ZFLocalizedString(@"Contacts_VC_Send",nil),(unsigned long)array.count];
                }
            }
            [self.sendButton setTitle:countStr forState:UIControlStateNormal];
            
            NSMutableArray *temp = [NSMutableArray array];
            for (PPPersonModel *model in array) {
                NSString *phone = [NSString stringWithFormat:@"%@",model.mobileArray.firstObject];
                [temp addObject:phone];
            }
            self.phoneArray = temp;
        };
    }
    return _viewModel;
}

-(UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([SystemConfigUtils isRightToLeftShow]) {
            [_sendButton setTitle:[NSString stringWithFormat:@"(0)%@",ZFLocalizedString(@"Contacts_VC_Send",nil)] forState:UIControlStateNormal];
            ;
        } else {
            [_sendButton setTitle:[NSString stringWithFormat:@"%@(0)",ZFLocalizedString(@"Contacts_VC_Send",nil)] forState:UIControlStateNormal];
        }
        
        [_sendButton addTarget:self action:@selector(sendBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _sendButton.frame = CGRectMake(0, 0, 60, 40);
        [_sendButton setTitleColor:ZFCOLOR(255, 168, 0, 1) forState:UIControlStateNormal];
        [_sendButton setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:18];
        _sendButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_sendButton sizeToFit];
    }
    return _sendButton;
}

-(NSMutableArray *)phoneArray {
    if (!_phoneArray) {
        _phoneArray = [NSMutableArray array];
    }
    return _phoneArray;
}

@end
