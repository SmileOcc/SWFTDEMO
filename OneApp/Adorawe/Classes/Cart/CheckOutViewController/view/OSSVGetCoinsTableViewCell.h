//
//  OSSVGetCoinsTableViewCell.h
// XStarlinkProject
//
//  Created by Kevin on 2021/3/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVTableViewCellProtocol.h"
#import "OSSVCheckOutBaseCellModel.h"

@protocol OSSVGetCoinsTableViewCellDelegate <NSObject>

@optional
- (void)coinInstructionPopView;

@end
 
@interface OSSVGetCoinsTableViewCell : UITableViewCell <OSSVTableViewCellProtocol>

@property (nonatomic, weak) id <OSSVGetCoinsTableViewCellDelegate> delegate;
@end


#pragma mark ---
@interface STLGetCoinsTableViewCellModel : OSSVCheckOutBaseCellModel

+(instancetype)initWithTitile:(NSString *)title;

@property (nonatomic, copy) NSString *titleContent;

@end
