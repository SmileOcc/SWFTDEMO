//
//  OSSVMysSizesCell.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVSizesModel.h"

NS_ASSUME_NONNULL_BEGIN
/// cell 类型
typedef enum : NSUInteger {
    sizeCellTypeSize = 0,
    sizeCellTypeGender,
    sizeCellTypeHeight,
    sizeCellTypeWeight,
    sizeCellTypeShap,
    
} sizeCellType;

/// cell 中点击类型
typedef enum : NSUInteger {
    sizeDidSelecteTypeSize = 0,
    sizeDidSelecteTypeGender,
    sizeDidSelecteTypeShap,
    
} sizeDidSelecteType;

/// 点中了cell中的哪个类型的哪个选项
typedef void(^sizeDidSelectedBlock)(sizeCellType cellType, NSInteger row);

typedef void(^changeSizeDescBlock)(NSString *desc);

@interface OSSVMysSizesCell : UITableViewCell

@property (nonatomic, strong)OSSVSizesModel  *sizeModel;

@property (nonatomic, assign)sizeCellType cellType;

@property (nonatomic, copy)sizeDidSelectedBlock sizeDidSelectedblock;
@property (nonatomic, copy)changeSizeDescBlock changeSizeDsceblock;

// 返回cell高度
+ (CGFloat)getHeightWithType:(sizeCellType)cellType;
@end

NS_ASSUME_NONNULL_END
