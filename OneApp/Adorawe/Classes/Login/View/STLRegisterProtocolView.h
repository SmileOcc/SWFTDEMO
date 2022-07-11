//
//  STLRegisterProtocolView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/15.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYLabel.h"
#import "YYText.h"

@class STLRegisterProtocolView;

typedef NS_ENUM(NSInteger, RegisterProtocolEvent) {
    RegisterProtocolEventSelected = 1,
    RegisterProtocolEventTerm,
    RegisterProtocolEventPolicy,
    RegisterProtocolEventSure
};

@protocol STLRegisterProtocolViewDelegate<NSObject>

- (void)registerProtocol:(STLRegisterProtocolView *)protocolView event:(RegisterProtocolEvent)event;

@end

@interface STLRegisterProtocolView : UIView

@property (nonatomic, weak) id<STLRegisterProtocolViewDelegate>   delegate;

@property (nonatomic, strong) NSMutableArray       *serviceDatas;
@property (nonatomic, strong) UIView               *contentView;
@property (nonatomic, strong) UITableView          *protocolTable;
@property (nonatomic, strong) UIButton             *cancelButton;
@property (nonatomic, strong) UIButton             *sureButton;
@property (nonatomic, strong) UIView               *lineView;
@property (nonatomic, strong) UIView               *verLineView;
@property (nonatomic, assign) BOOL                 isSure;
@property (nonatomic, assign) BOOL                 isAllSelected;

- (void)show:(UIView *)superView;

@end


@interface STLRegisterProtocolCell : UITableViewCell

@property (nonatomic, strong) UIImageView          *iconImageView;
@property (nonatomic, strong) UIButton             *selectButton;
@property (nonatomic, strong) YYLabel              *conditionLabel;
@property (nonatomic, strong) YYLabel              *msgLabel;

@property (nonatomic, assign) BOOL                 isSure;

@property (nonatomic,copy) void (^protocolBlock)(STLRegisterProtocolCell *cell, RegisterProtocolEvent event);

- (void)updateCellDic:(NSDictionary *)contentDic isSure:(BOOL)sure;



@end
