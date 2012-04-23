//
//  JAS8QueensSolution.h
//  EightQueensAlgo
//
//  Created by Josh Smith on 4/10/12.
//  Copyright (c) 2012 iJoshSmith. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JAS8QueensChromosome;

@interface JAS8QueensSolution : NSObject

@property (nonatomic, readonly, strong) JAS8QueensChromosome *chromosome;
@property (nonatomic, readonly, assign) NSUInteger rowCount;
@property (nonatomic, readonly, assign) NSUInteger columnCount;
@property (nonatomic, readonly, assign) NSUInteger generation;

// Designated initializer
- (id)initWithChromosome:(JAS8QueensChromosome *)chromosome 
          fromGeneration:(NSUInteger)gen;

// Returns YES if a queen exists at the specified location.
- (BOOL)isQueenAtRow:(NSUInteger)row 
              column:(NSUInteger)column;

// Outputs a diagram of the solution to the console.
- (void)printDescription;

@end
