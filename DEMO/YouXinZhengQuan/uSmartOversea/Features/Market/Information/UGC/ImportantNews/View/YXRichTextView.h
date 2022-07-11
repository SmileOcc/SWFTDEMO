//
//  YXRichTextView.h
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface YXRichTextView : UIView

@property (nonatomic, strong) NSAttributedString *attText;

@property (nonatomic, copy) void (^refreshHeight)(CGFloat height);

@end

NS_ASSUME_NONNULL_END
