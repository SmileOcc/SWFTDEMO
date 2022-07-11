//
//  YXMobileBrief1Label.h
//  YouXinZhengQuan
//
//  Created by ellison on 2018/12/18.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXSecuMobileBrief1Protocol.h"

NS_ASSUME_NONNULL_BEGIN

@class YXWarrantsFundFlowRankItem;

@interface YXMobileBrief1Label : UILabel

@property (nonatomic, assign) YXMobileBrief1Type mobileBrief1Type;

@property (nonatomic, assign) id<YXSecuMobileBrief1Protocol> mobileBrief1Object;

@property (nonatomic, strong) YXWarrantsFundFlowRankItem *warrantsModel;

+ (instancetype)labelWithMobileBrief1Type:(YXMobileBrief1Type)mobileBrief1Type;

@end

NS_ASSUME_NONNULL_END
