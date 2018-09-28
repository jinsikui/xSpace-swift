//
//  ObjcView.m
//  xSpace-swift
//
//  Created by JSK on 2018/9/27.
//  Copyright © 2018年 JSK. All rights reserved.
//

#import "ObjcView.h"
#import "Masonry.h"

@implementation ObjcView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor greenColor];
        UIView *box = [[UIView alloc] init];
        box.backgroundColor = [UIColor redColor];
        [self addSubview:box];
        [box mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.height.mas_equalTo(20);
        }];
    }
    return self;
}

@end
