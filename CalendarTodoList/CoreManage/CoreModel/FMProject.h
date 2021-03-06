//
//  FMProject.h
//  GoDo
//
//  Created by 牛严 on 16/5/4.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FMProject : NSObject
///事件类型ID 主键
@property (nonatomic, copy) NSString *projectId;
///事件类型字符串
@property (nonatomic, copy) NSString *projectStr;
///事件类型标记颜色
@property (nonatomic, assign) NSInteger red;
@property (nonatomic, assign) NSInteger green;
@property (nonatomic, assign) NSInteger blue;

@end
