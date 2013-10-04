//
//  MyTest.m
//  Initializer
//
//  Created by Carl Jahn on 11.07.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import "SyncedTestCases.h"
#import "CJAStarter.h"

@interface SyncedTestCases ()

@property (nonatomic, strong) CJAStarter *starter;

@end

@implementation SyncedTestCases

- (void)setUp {
  self.starter = [CJAStarter new];
}

- (void)test1 {
  
  __block int index = 0;
  [self.starter addTaskBlock:^(CJAStarterTask *task){
    index = 1;
  }];
  [self.starter start];
  
  XCTAssertEqual(1, index, @"indexes arent the same");
}


- (void)test2 {
    
  __block int index = 0;
  [self.starter addTaskBlock:^(CJAStarterTask *task){
    index = 1;
  }];
  
  [self.starter addTaskBlock:^(CJAStarterTask *task){
    index = 2;
  }];
  [self.starter start];
  
  XCTAssertEqual(2, index, @"indexes arent the same");
}

- (void)test3 {
  
  __block int index = 0;
  CJAStarterTask *task1 = [self.starter addTaskBlock:^(CJAStarterTask *task){
    index = 2;
  }];
  
  CJAStarterTask *task2 = [self.starter addTaskBlock:^(CJAStarterTask *task){
    index = 1;
  }];
  
  task1.dependencieTask = task2;
  [self.starter start];
  
  XCTAssertEqual(1, index, @"indexes arent the same");
}

- (void)test4 {

  __block int index = 0;
  CJAStarterTask *task1 = [[CJAStarterTask alloc] initWithTask:^(CJAStarterTask *task){
    index = 1;
  }];
  [self.starter addTask: task1];
  
  
  [self.starter start];
  
  XCTAssertEqual(1, index, @"indexes arent the same");
  
}


@end
