//
//  InitializerFactory.m
//  Initializer
//
//  Created by Carl Jahn on 10.07.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import "CJAStarter.h"
#import <libkern/OSAtomic.h>

#define kObservedKeyPath @"finished"

NSString *const CJAStarterStartedNotificationName = @"InitializerFactoryStartedNotificationName";
NSString *const CJAStarterFinishedNotificationName = @"InitializerFactoryFinishedNotificationName";


@interface CJAStarter (){
  NSArray *_tasks;
  int32_t _actvitiy;
}

@end

@implementation CJAStarter

- (id)init {
  self = [super init];
  
  if (self) {
    _actvitiy = 0;
    _tasks = @[];
  }
  
  return self;
}

+ (id)sharedInstance {
  
  static id sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [self.class new];
  });
  
  return sharedInstance;
}

- (void)addTask:(CJAStarterTask *)task {
  
  if (!task) {
    return;
  }
  
  _tasks = [_tasks arrayByAddingObject: task ];
}


- (CJAStarterTask *)addTaskClass:(Class)class {
  
  if (![class isSubclassOfClass: [CJAStarterTask class]] ) {
    return nil;
  }
  
  CJAStarterTask *newCJAStarter = [class new];
  _tasks = [_tasks arrayByAddingObject: newCJAStarter ];
  
  return newCJAStarter;
}

- (CJAStarterTask *)addTaskBlock:(CJAStarterTaskBlock)task{
  
  if (!task) {
    return nil;
  }
  
  CJAStarterTask *blockCJAStarter = [[CJAStarterTask alloc] initWithTask:task];
  _tasks = [_tasks arrayByAddingObject: blockCJAStarter];
  
  return blockCJAStarter;
}

- (CJAStarterTask *)addAsyncTaskBlock:(CJAStarterTaskBlock)task {
  CJAStarterTask *asyncTask = [self addTaskBlock:task];
  asyncTask.async = YES;
  
  return asyncTask;
}


- (void)start {
  
  if (![NSThread isMainThread]) {
    [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
    return;
  }
  
  @synchronized(self) {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CJAStarterStartedNotificationName object:self];
    
    [self setActivityCount: _tasks.count];
    
    if (!_tasks.count) {
      [self shouldFinish];
      return;
    }
    
    for (CJAStarterTask *i in _tasks) {
      
      if ( i.finished ) {
        [self decrementActivityCount];
        continue;
      }
      
      [i addObserver:self forKeyPath:kObservedKeyPath options:NSKeyValueObservingOptionNew context:NULL];
      if (!i.executing) {
        [i run];
      }
      
    }
    
  }
  
}

- (void)setActivityCount:(int32_t)value {
  _actvitiy = value;
}

- (void)decrementActivityCount {
  OSAtomicDecrement32((int32_t*)&_actvitiy);
  
  [self shouldFinish];
}

- (void)shouldFinish {
  
  if (!_actvitiy) {
    
    _tasks = @[];
    [self setActivityCount: 0];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [[NSNotificationCenter defaultCenter] postNotificationName:CJAStarterFinishedNotificationName object:self];
    });
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  
  if ([object isKindOfClass: [CJAStarterTask class] ] && [keyPath isEqualToString: kObservedKeyPath]) {
    
    if ([(CJAStarterTask *)object isFinished]) {
      
      [object removeObserver:self forKeyPath: kObservedKeyPath];
      [self decrementActivityCount];
    }
  }
  
}

@end


//***********************//


@implementation CJAStarterTask

- (id)init {
  
  self = [super init];
  if (self) {
    _finished = NO;
    _executing = NO;
    _async = NO;
  }
  
  return self;
}

- (id)initWithTask:(CJAStarterTaskBlock)task {
  
  self = [self init];
  if (self) {
    _task = task;
  }
  
  return self;
  
}

- (id)initWithAsyncTask:(CJAStarterTaskBlock)task {
  
  self = [self initWithTask: task];
  if (self) {
    _async = YES;
  }
  
  return self;
}

- (void)run {
  
  if (_dependencieTask && !_dependencieTask.finished) {
    
    [_dependencieTask addObserver:self forKeyPath:kObservedKeyPath options:NSKeyValueObservingOptionNew context:NULL];
    [_dependencieTask run];
    
    if (!_dependencieTask.isAsync) {
      _dependencieTask.finished = YES;
    }
    return;
  }
  
  _dependencieTask = nil;
  
  if (!_task) {
    
    return;
  }
  
  self.executing = YES;
  
  __block CJAStarterTask *blockSelf = self;
  
  if (_async) {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
      _task(blockSelf);
      _task = nil;
      
    });
    
    return;
    
  }

  _task(blockSelf);
  _task = nil;
  self.executing = NO;
  self.finished = YES;
  
  
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

  if (object == _dependencieTask && [keyPath isEqualToString: kObservedKeyPath] && _dependencieTask.isFinished) {

    [object removeObserver:self forKeyPath: kObservedKeyPath];
    [self performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:NO];
  }
  
}



@end
