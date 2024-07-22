//
//  BoletoFinishedViewController.m
//  ZZZZZ
//
//  Created by YW on 15/8/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BoletoFinishedViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFCartViewController.h"
#import "BoletoApi.h"
#import "ZFMyOrderListViewController.h"
#import "ZFPaymentViewController.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import <YYWebImage/YYWebImage.h>
#import "NSStringUtils.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "Masonry.h"
#import "ZFNavigationController.h"
#import "Constants.h"

@interface BoletoFinishedViewController ()<ZFInitViewProtocol>
@property (nonatomic, strong) YYLabel   *orderLabel; // 顶部订单
@property (nonatomic, strong) YYLabel   *boldLabel;  // 加粗标题
@property (nonatomic, strong) YYLabel   *numOneLabel; // 标题一
@property (nonatomic, strong) UIButton  *contiueButton; // 继续支付按钮
@property (nonatomic, strong) YYLabel   *middleLabel; // 中间段文字
@property (nonatomic, strong) YYLabel   *bottomLabel; // 底部文字
@property (nonatomic, strong) UIButton  *returnButton;// 返回首页按钮
@property (nonatomic, strong) UIButton  *shoppingCarBtn;
@end

@implementation BoletoFinishedViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitleView:[[YYAnimatedImageView alloc]initWithImage:[UIImage imageNamed:@"ZZZZZ"]]];
    [self setNavagationBar];
    [self zfInitView];
    [self zfAutoLayoutView];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    [self.view addSubview:self.orderLabel];
    [self.view addSubview:self.boldLabel];
    [self.view addSubview:self.numOneLabel];
    [self.view addSubview:self.contiueButton];
    [self.view addSubview:self.middleLabel];
    [self.view addSubview:self.bottomLabel];
    [self.view addSubview:self.returnButton];
}

- (void)zfAutoLayoutView {
    [self.orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(32);
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
    }];
    
    [self.boldLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.orderLabel.mas_bottom).offset(32);
        make.leading.equalTo(self.orderLabel.mas_leading);
    }];
    
    [self.numOneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.boldLabel.mas_leading);
        make.top.equalTo(self.boldLabel.mas_bottom).offset(16);
    }];
    
    [self.contiueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.numOneLabel.mas_trailing).offset(4);
        make.trailing.equalTo(self.view.mas_trailing).offset(-10);
        make.centerY.equalTo(self.numOneLabel);
        make.height.mas_equalTo(44);
    }];
    
    [self.middleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.numOneLabel.mas_bottom).offset(16);
        make.leading.equalTo(self.numOneLabel.mas_leading);
        make.trailing.mas_equalTo(-24);
    }];
    
    [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.middleLabel.mas_bottom).offset(32);
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
    }];
    
    [self.returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomLabel.mas_bottom).offset(32);
        make.leading.equalTo(self.contiueButton.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing).offset(-10);
        make.height.mas_equalTo(44);
    }];
    
}

- (void)setNavagationBar{
    
    [self.navigationItem setTitleView:[[YYAnimatedImageView alloc]initWithImage:[UIImage imageNamed:@"ZZZZZ"]]];
    
    UIImage *image = [UIImage imageNamed:@"nav_arrow_left"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(searchClick)];
    
    //购物车按钮
    self.shoppingCarBtn = [self showNavigationRightCarBtn:ZF_BoletoFinished_Cars_type];
}

- (void)searchClick {
    [self dismissViewControllerAnimated:YES completion:nil];
    ZFNavigationController  *accountNavVC = [self queryTargetNavigationController:TabBarIndexAccount];
    ZFMyOrderListViewController *orderListVC = [[ZFMyOrderListViewController alloc] init];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [accountNavVC pushViewController:orderListVC animated:NO];
}

#pragma mark - Target Action
- (void)contiuePay {
    BoletoApi *api = [[BoletoApi alloc] initWithOrderID:self.order_id];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
         id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(BoletoApi.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            NSDictionary *dict = requestJSON[ZFResultKey];
            NSString *url = [dict ds_stringForKey:@"pay_url"];
            
            ZFPaymentViewController *payVC = [[ZFPaymentViewController alloc] init];
            payVC.url = url;
            [self.navigationController pushViewController:payVC animated:YES];
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        
    }];
}

- (void)backToHome {
    [self dismissViewControllerAnimated:YES completion:nil];
    ZFNavigationController  *homeNavVC = [self queryTargetNavigationController:TabBarIndexHome];
    [homeNavVC popToRootViewControllerAnimated:YES];
}

- (ZFNavigationController *)queryTargetNavigationController:(NSInteger)index {
    ZFTabBarController *tabBarVC = APPDELEGATE.tabBarVC;
    ZFNavigationController  *currentNavVC = (ZFNavigationController *)tabBarVC.selectedViewController;
    [currentNavVC popToRootViewControllerAnimated:NO];
    tabBarVC.selectedIndex       = index;
    ZFNavigationController  *targetNavVC = (ZFNavigationController *)tabBarVC.selectedViewController;
    return targetNavVC;
}

#pragma mark - Setter
-(void)setOrder_number:(NSString *)order_number {
    _order_number = order_number;
    
    NSString *string = [NSString stringWithFormat:@"Obrigado por comprar conosco!\nO seu pedido %@ foi recebido!",_order_number];
    NSRange range = [string rangeOfString:_order_number];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    text.yy_font = [UIFont systemFontOfSize:14];
    text.yy_color = ZFCOLOR(153, 153, 153, 1);
    [text yy_setColor:ZFCOLOR(51, 51, 51, 1) range:range];
    text.yy_lineSpacing = 8;
    self.orderLabel.attributedText = text;
}

#pragma mark - Getter
- (YYLabel *)orderLabel {
    if (!_orderLabel) {
        _orderLabel = [YYLabel new];
        _orderLabel.numberOfLines = 0;
        _orderLabel.preferredMaxLayoutWidth = KScreenWidth - 48;
        _orderLabel.font = [UIFont systemFontOfSize:14];
        _orderLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _orderLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _orderLabel;
}

- (YYLabel *)boldLabel {
    if (!_boldLabel) {
        _boldLabel = [YYLabel new];
        _boldLabel.font = [UIFont boldSystemFontOfSize:16];
        _boldLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _boldLabel.textAlignment = NSTextAlignmentLeft;
        _boldLabel.text = @"Agora você deve:";
    }
    return _boldLabel;
}

-(YYLabel *)numOneLabel {
    if (!_numOneLabel) {
        _numOneLabel = [YYLabel new];
        _numOneLabel.font = [UIFont boldSystemFontOfSize:14];
        _numOneLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _numOneLabel.textAlignment = NSTextAlignmentLeft;
        _numOneLabel.text = @"1.";
    }
    return _numOneLabel;
}

-(UIButton *)contiueButton {
    if (!_contiueButton) {
        _contiueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_contiueButton setTitle:@"VERIFIQUE O BOLETO BANCARIO" forState:UIControlStateNormal];
        [_contiueButton setTitleColor:ZFCOLOR(255, 255, 255, 1) forState:UIControlStateNormal];
        [_contiueButton addTarget:self action:@selector(contiuePay) forControlEvents:UIControlEventTouchUpInside];
        [_contiueButton setBackgroundColor:ZFCOLOR(255, 168, 0, 1)];
        _contiueButton.contentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
    }
    return _contiueButton;
}

-(YYLabel *)middleLabel {
    if (!_middleLabel) {
        _middleLabel = [YYLabel new];
        _middleLabel.font = [UIFont systemFontOfSize:14];
        _middleLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _middleLabel.textAlignment = NSTextAlignmentLeft;
        _middleLabel.numberOfLines = 0;
        _middleLabel.preferredMaxLayoutWidth = KScreenWidth - 56;
        _middleLabel.text = @"2.Pague em qualquer banco, casas lotéricas ou em sua pelo seu banco na online, você tem 3 dias para completar seu pagamento.";
    }
    return _middleLabel;
}

-(YYLabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [YYLabel new];
        _bottomLabel.font = [UIFont systemFontOfSize:14];
        _bottomLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
        _bottomLabel.numberOfLines = 0;
        _bottomLabel.preferredMaxLayoutWidth = KScreenWidth - 56;
        _bottomLabel.text = @"Aviso prévio:\nO status do seu pedido mudará para 'processando' dentro de 1-2 dias úteis após verificarmos seu pagamento. Alguns pedidos podem exigir mais tempo para serem verificados. Por favor, aguarde.";
    }
    return _bottomLabel;
}

-(UIButton *)returnButton {
    if (!_returnButton) {
        _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_returnButton setTitle:@"RETORNAR PARA MINHA CONTA" forState:UIControlStateNormal];
        [_returnButton setTitleColor:ZFCOLOR(255, 255, 255, 1) forState:UIControlStateNormal];
        [_returnButton addTarget:self action:@selector(backToHome) forControlEvents:UIControlEventTouchUpInside];
        [_returnButton setBackgroundColor:ZFCOLOR(51, 51, 51, 1)];
        _returnButton.contentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
    }
    return _returnButton;
}

@end
