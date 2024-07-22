//
//  ZFSelectLiveCommentHeader.h
//  ZZZZZ
//
//  Created by YW on 2019/12/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFSelectLiveCommentHeader : UICollectionReusableView

@property (nonatomic, assign) NSInteger commentNums;
@property (nonatomic, assign) BOOL      isLiveMark;

@property (nonatomic, copy) void (^commentBlock)(void);

- (void)updateCommentNums:(NSInteger)nums liveMark:(BOOL)isMrak;

@end

NS_ASSUME_NONNULL_END
