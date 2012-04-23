//
//  JASEightQueensAlgo.h
//  EightQueensAlgo
//
//  Created by Josh Smith on 4/10/12.
//  Copyright (c) 2012 iJoshSmith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAS8QueensAlgorithm : NSObject

@property (nonatomic, readonly, strong) NSMutableSet *solutions;

- (void)execute;

@end
