//
//  CJAStarter
//
//  Created by Carl Jahn on 10.07.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

@import Foundation;

extern NSString *const CJAStarterFinishedNotificationName;
extern NSString *const CJAStarterStartedNotificationName;

@class CJAStarterTask;
typedef void(^CJAStarterTaskBlock)(CJAStarterTask *initializer);

@interface CJAStarter : NSObject

+ (id)sharedInstance;

- (void)addTask:(CJAStarterTask *)task;
- (CJAStarterTask *)addTaskClass:(Class)class;
- (CJAStarterTask *)addTaskBlock:(CJAStarterTaskBlock)task;
- (CJAStarterTask *)addAsyncTaskBlock:(CJAStarterTaskBlock)task;

- (void)start;

@end


//***********************//
@interface CJAStarterTask : NSObject

- (id)initWithTask:(CJAStarterTaskBlock)task;
- (id)initWithAsyncTask:(CJAStarterTaskBlock)task;

@property (nonatomic, copy) CJAStarterTaskBlock task;
@property (nonatomic, strong) CJAStarterTask *dependencieTask;

- (void)run;

@property (nonatomic, assign, getter = isAsync)     BOOL async;
@property (nonatomic, assign, getter = isFinished)  BOOL finished;
@property (nonatomic, assign, getter = isExecuting) BOOL executing;


@end
