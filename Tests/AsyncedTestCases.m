//
//  AsyncedTestCases.m
//  Initializer
//
//  Created by Carl Jahn on 11.07.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import "AsyncedTestCases.h"
#import "CJAStarter.h"

@interface AsyncedTestCases ()

@property (nonatomic, strong) CJAStarter *starter;
@property (nonatomic, assign) SEL currentSelector;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end


@implementation AsyncedTestCases

- (void)setUp {
  [super setUp];
  
  self.semaphore = dispatch_semaphore_create(0);
  
  self.starter = [CJAStarter new];
}

- (void)test1 {
  
  self.currentSelector = _cmd;
  
  __block int index = 0;
  __block typeof(self) blockSelf = self;
  [self.starter addAsyncTaskBlock:^(CJAStarterTask *task){

    index = 1;
    task.finished = YES;
    dispatch_semaphore_signal(blockSelf.semaphore);
  }];
  
  
  [self.starter start];
  dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);

  XCTAssertEqual(1, index, @"indexes arent the same");
}

- (void)test2 {
  
  self.currentSelector = _cmd;

  __block int index = 0;
  
  [self.starter addAsyncTaskBlock:^(CJAStarterTask *task){
    
    sleep(1);
    index = 1;
    task.finished = YES;
  }];
  
  __block typeof(self) blockSelf = self;
  [self.starter addAsyncTaskBlock:^(CJAStarterTask *task){
    
    sleep(2);
    index = 2;
    task.finished = YES;
    dispatch_semaphore_signal(blockSelf.semaphore);
  }];
  
  
  [self.starter start];
  dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
  
  
  
  XCTAssertEqual(2, index, @"indexes arent the same");
}

- (void)test3 {

  self.currentSelector = _cmd;
  
  __block int index = 0;
  CJAStarterTask *task1 = [self.starter addAsyncTaskBlock:^(CJAStarterTask *task){
    sleep(1);
    index = 1;
    task.finished = YES;
  }];
  
  __block typeof(self) blockSelf = self;
  CJAStarterTask *task2 = [self.starter addAsyncTaskBlock:^(CJAStarterTask *task){
    
    sleep(2);
    index = 2;
    task.finished = YES;
    dispatch_semaphore_signal(blockSelf.semaphore);
  }];
  
  task1.dependencieTask = task2;
  [self.starter start];
  dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);

  
  XCTAssertEqual(2, index, @"indexes arent the same");
}

@end