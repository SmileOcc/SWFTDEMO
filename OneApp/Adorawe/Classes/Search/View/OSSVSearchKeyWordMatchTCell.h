//
//  OSSVSearchKeyWordMatchTCell.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^SearchMatchRightBlock)(NSString *keyWord);

@interface OSSVSearchKeyWordMatchTCell : UITableViewCell

@property (nonatomic, copy) NSString *key;// 输入的key

@property (nonatomic, copy) NSString *keyWord;// 联想的关键字

@property (nonatomic, copy) SearchMatchRightBlock SearchMatchRightblock;// 点击右边按钮

@end

NS_ASSUME_NONNULL_END
