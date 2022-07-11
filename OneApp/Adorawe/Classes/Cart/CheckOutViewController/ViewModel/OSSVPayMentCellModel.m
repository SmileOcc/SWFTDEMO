//
//  OSSVPayMentCellModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVPayMentCellModel.h"

@implementation OSSVPayMentCellModel
@synthesize indexPath = _indexPath;
@synthesize showSeparatorStyle = _showSeparatorStyle;

- (instancetype)init{
    self = [super init];
    if (self) {
        self.showSeparatorStyle = NO;
        self.payMentModel = [[OSSVCartPaymentModel alloc] init];
        self.depenDentModelList = [[NSMutableArray alloc] init];
        self.checkModel   = [[OSSVCartCheckModel alloc] init];
    }
    return self;
}
#pragma mark - protocol

+(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}

-(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}

#pragma mark - setter and getter

-(void)setPayMentModel:(OSSVCartPaymentModel *)payMentModel{
    _payMentModel = payMentModel;
    self.paymentTitle = [[NSAttributedString alloc] initWithString:_payMentModel.payName];
    self.paymentIcon = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:STLToString(_payMentModel.payIconUrlStr)]]];
    if ([_payMentModel.payCode isEqualToString:@"Cod"]) {
//        NSString *recommendString = [NSString stringWithFormat:@"(%@)", STLLocalizedString_(@"Recommend", nil)];
        NSMutableAttributedString *mutAttriString = [[NSMutableAttributedString alloc] initWithString:
                                                     [NSString stringWithFormat:@"%@", _payMentModel.payName]];
        if (_payMentModel.isOptional) {
            self.showDetail = NO;
//            self.paymentIcon = [UIImage imageNamed:@"cod_new_icon"];
            NSRange paymentRange = [mutAttriString.string rangeOfString:_payMentModel.payName];
            [mutAttriString addAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} range:paymentRange];
//            NSRange recomRange = [mutAttriString.string rangeOfString:recommendString];
//            [mutAttriString addAttributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_B62B21}  range:recomRange];

        } else {
            self.showDetail = YES;
            self.paymentDetail = _payMentModel.payHelp;
//            self.paymentIcon = [UIImage imageNamed:@"cod_new_icon_unenable"];
            [mutAttriString addAttributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_999999} range:NSMakeRange(0, mutAttriString.string.length)];
        }
        self.paymentTitle = [mutAttriString copy];
    }
    
    //*****************************以下不用，根据接口返回的图标以及标题去赋值***************************//
//    if ([_payMentModel.payCode isEqualToString:@"PayPalCredit"]) {
//
//        self.paymentIcon = [UIImage imageNamed:@"pay_credit"];
//        self.paymentTitle = [[NSAttributedString alloc] initWithString:_payMentModel.payName];
//
//    } else if ([_payMentModel.payCode isEqualToString:@"PayPal"]) {
//
//        self.paymentIcon = [UIImage imageNamed:@"paypal_new"];
//        self.paymentTitle = [[NSAttributedString alloc] initWithString:_payMentModel.payName];
//
//    } else if ([_payMentModel.payCode isEqualToString:@"webcollect"]) {
//
//        self.paymentIcon = [UIImage imageNamed:@"visa"];
//        self.paymentTitle = [[NSAttributedString alloc] initWithString:_payMentModel.payName];
//
//    } else if ([_payMentModel.payCode isEqualToString:@"WesternUnion"]) {
//        self.paymentIcon = [UIImage imageNamed:@"western"];
//        if (![OSSVNSStringTool isEmptyString:_payMentModel.payDiscount]) {
//            self.paymentTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)",_payMentModel.payName,_payMentModel.payDesc]];
//
//        } else {
//            self.paymentTitle = [[NSAttributedString alloc] initWithString:_payMentModel.payName];
//        }
//
//    } else if ([_payMentModel.payCode isEqualToString:@"WorldPay"]) {
//        self.paymentIcon = [UIImage imageNamed:@"creditcard"];
//        self.paymentTitle = [[NSAttributedString alloc] initWithString:_payMentModel.payDesc];
//
//    } else if ([_payMentModel.payCode isEqualToString:@"Cod"]) {
////        NSString *recommendString = [NSString stringWithFormat:@"(%@)", STLLocalizedString_(@"Recommend", nil)];
//        NSMutableAttributedString *mutAttriString = [[NSMutableAttributedString alloc] initWithString:
//                                                     [NSString stringWithFormat:@"%@", _payMentModel.payName]];
//        if (_payMentModel.isOptional) {
//            self.showDetail = NO;
//            self.paymentIcon = [UIImage imageNamed:@"cod_new_icon"];
//            NSRange paymentRange = [mutAttriString.string rangeOfString:_payMentModel.payName];
//            [mutAttriString addAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} range:paymentRange];
////            NSRange recomRange = [mutAttriString.string rangeOfString:recommendString];
////            [mutAttriString addAttributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_B62B21}  range:recomRange];
//
//        } else {
//            self.showDetail = YES;
//            self.paymentDetail = _payMentModel.payHelp;
//            self.paymentIcon = [UIImage imageNamed:@"cod_new_icon_unenable"];
//            [mutAttriString addAttributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_999999} range:NSMakeRange(0, mutAttriString.string.length)];
//        }
//        self.paymentTitle = [mutAttriString copy];
//
//    } else if ([_payMentModel.payCode isEqualToString:@"OnlinePayment"]){
//        self.paymentIcon = [UIImage imageNamed:@"creditcard"];
//        self.paymentTitle = [[NSAttributedString alloc] initWithString:_payMentModel.payDesc];
//
//    } else {
//        self.paymentIcon = [UIImage imageNamed:@"pay_credit"];
//        self.paymentTitle = [[NSAttributedString alloc] initWithString:_payMentModel.payName];
//    }
}

@end
