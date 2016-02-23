//
//  Thing.h
//  CalendarTodoList
//
//  Created by 牛严 on 16/1/28.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThingType.h"

@interface Thing : NSObject
///事件类型
@property (nonatomic, strong) ThingType *thingType;
///事件字符串
@property (nonatomic, copy) NSString *thingStr;
///图片数组
@property (nonatomic, strong) NSArray *images;

@end
