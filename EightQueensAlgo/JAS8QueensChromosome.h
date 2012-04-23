//
//  JAS8QueensChromosome.h
//  EightQueensAlgo
//
//  Created by Josh Smith on 4/10/12.
//  Copyright (c) 2012 iJoshSmith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAS8QueensChromosome : NSObject

@property (nonatomic, readonly) NSInteger fitness;
@property (nonatomic, readonly) NSString *geneSequence;
@property (nonatomic, readonly) BOOL hasPerfectFitness;
@property (nonatomic, readonly) BOOL hasValidGenes;

// Designated initializer.
- (id)initWithGeneSequence:(NSString *)sequence;
- (id)initWithRandomGeneSequence;

- (NSComparisonResult)compareFitnessWithChromosome:(JAS8QueensChromosome *)other;

- (JAS8QueensChromosome *)mateWithChromosome:(JAS8QueensChromosome *)other;

@end
