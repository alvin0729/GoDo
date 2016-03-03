//
//  RealmManage.h
//  CalendarTodoList
//
//  Created by 牛严 on 16/1/27.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLMTodo.h"

#define RealmManager [RealmManage sharedInstance]

@class Project;

@interface RealmManage : NSObject

+ (id)sharedInstance;

#pragma mark 根据dayId获取todo数组
- (NSArray *)getDayInfoFromRealmWithDayId:(NSInteger)dayId;

#pragma mark 根据project返回类型字符串
- (Project *)getProjectWithId:(NSInteger)projectId;

#pragma mark 获取project数组
- (NSMutableArray *)getProjectArray;

#pragma mark 创建RLMTodo
- (void)createTodoWithProject:(Project *)project contentStr:(NSString *)contentStr contentImages:(NSArray *)images startDate:(NSDate *)startDate tableId:(NSInteger)tableId;

#pragma mark 根据todo tableID 修改todo 的doneType完成情况
- (void)changeTodoDoneTypeWithTableId:(NSInteger)tableId doneType:(DoneType)doneType;

#pragma mark 删除todo
- (void)deleteTodoWithTableId:(NSInteger)tableId;

@end
