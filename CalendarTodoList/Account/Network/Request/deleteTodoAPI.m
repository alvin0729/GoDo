//
//  deleteTodoAPI.m
//  GoDo
//
//  Created by 牛严 on 16/4/7.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import "deleteTodoAPI.h"

@implementation deleteTodoAPI
{
    NSString *_todoId;
}

- (id)initWithTodoId:(NSString *)todoId
{
    self = [super init];
    if (self) {
        _todoId = todoId;
    }
    return self;
}

- (NSString *)requestUrl {
    NSString *url = [NSString stringWithFormat:@"/todos/%@",_todoId];
    return url;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodDelete;
}


@end
