//
//  ZFSurveyViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/1/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFSurveyViewController.h"
#import "JumpManager.h"

@interface ZFSurveyViewController ()

@end

@implementation ZFSurveyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    //设置一个 “X” 按钮
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"z-me_outfits_post_close"]
//                                                                                              imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
//                                                                                       style:UIBarButtonItemStylePlain
//                                                                                      target:self
//                                                                                      action:@selector(goBackAction)];
//    self.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, -5);
}

//-(void)goBackAction
//{
//    if (self.navigationController) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }else{
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    
    if ([url.absoluteString rangeOfString:@"close-window"].location != NSNotFound) {
        //回到首页
        decisionHandler(WKNavigationActionPolicyCancel);
        JumpModel *model = [[JumpModel alloc] init];
        model.actionType = JumpHomeActionType;
        [JumpManager doJumpActionTarget:self withJumpModel:model];
    }else{
        [super webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
}

@end
