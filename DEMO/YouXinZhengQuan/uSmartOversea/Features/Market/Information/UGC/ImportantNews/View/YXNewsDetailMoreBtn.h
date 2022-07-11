//
//  YXNewsDetailMoreBtn.h
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/6/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, YXNewsDetailMoreType) {
    YXNewsDetailMoreTypeCollection = 0,
    YXNewsDetailMoreTypeShare,
    YXNewsDetailMoreTypeFont,
    YXNewsDetailMoreTypeTranslate,
    YXNewsDetailMoreTypeCopyURL,
};

typedef NS_ENUM(NSInteger, YXNewsDetailType) {
    YXNewsDetailTypeNews = 0,
    YXNewsDetailTypeArticle,
    YXNewsDetailTypeVideo,
};


@interface YXNewsDetailMoreBtn : UIButton

- (instancetype)initWithFrame:(CGRect)frame andTypeArr: (NSArray *)typeArr andNewsId: (NSString *)newsId andType: (YXNewsDetailType)type;

@property (nonatomic, copy) void (^subItemCallBack)(YXNewsDetailMoreType type);

@property (nonatomic, strong) NSDictionary *shareDic;

@end

NS_ASSUME_NONNULL_END
