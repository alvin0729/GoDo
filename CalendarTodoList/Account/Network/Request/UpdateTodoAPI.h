//
//  UpdateTodoAPI.h
//  GoDo
//
//  Created by 牛严 on 16/4/7.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import <YTKNetwork/YTKRequest.h>

@class TodoModel;

typedef void (^successBlock)();
typedef void (^failureBlock)();

@interface UpdateTodoAPI : YTKRequest

- (id)initWithTodo:(TodoModel *)todo pictures:(NSArray *)pictures;

- (void)startWithSuccessBlock:(successBlock)success failure:(failureBlock)failure;

@end
