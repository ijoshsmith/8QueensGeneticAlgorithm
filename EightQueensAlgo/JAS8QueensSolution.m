//
//  JAS8QueensSolution.m
//  EightQueensAlgo
//
//  Created by Josh Smith on 4/10/12.
//  Copyright (c) 2012 iJoshSmith. All rights reserved.
//

#import "JAS8QueensSolution.h"
#import "JAS8QueensChromosome.h"

@interface JAS8QueensSolution ()
@property (nonatomic, readwrite, strong) JAS8QueensChromosome *chromosome;
@property (nonatomic, readwrite, assign) NSUInteger rowCount;
@property (nonatomic, readwrite, assign) NSUInteger columnCount;
@property (nonatomic, readwrite, assign) NSUInteger generation;
@end

@implementation JAS8QueensSolution

@synthesize chromosome, rowCount, columnCount, generation;

- (id)initWithChromosome:(JAS8QueensChromosome *)aChromosome
            fromGeneration:(NSUInteger)gen
{
    self = [super init];
    if (self)
    {
        self.rowCount = ROW_COUNT;
        self.columnCount = COLUMN_COUNT;
        self.generation = gen;
        self.chromosome = aChromosome;
    }
    return self;
}

- (BOOL)isQueenAtRow:(NSUInteger)row column:(NSUInteger)column
{
    // Translate the (row, column) composite index into the 
    // gene that encodes for a queen at that location, and 
    // then check to see if that gene is in the sequence.
    NSUInteger gridIndex = (row * columnCount) + column;
    NSString *gene = [NSString stringWithFormat:@"%c", FIRST_GENE + gridIndex];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:gene];
    NSRange range = [self.chromosome.geneSequence rangeOfCharacterFromSet:set];
    BOOL hasGene = range.location != NSNotFound;
    return hasGene;
}

- (NSString *)description
{
    NSUInteger boardSize = self.rowCount * self.columnCount;
    NSMutableString *buffer = [NSMutableString stringWithCapacity:boardSize];
    for (NSUInteger row = 0; row < self.rowCount; ++row) 
    {
        for (NSUInteger column = 0; column < self.columnCount; ++column)
        {
            unichar value = [self isQueenAtRow:row column:column] ? 'Q' : '.';
            [buffer appendFormat:@" %c ", value];
        }
        [buffer appendString:@"\n"];
    }
    return [NSString stringWithFormat:
            @"Generation #%ld\n%@", 
            self.generation, 
            buffer];
}

- (void)printDescription
{
    NSLog(@"Gene Sequence: %@", self.chromosome.geneSequence);
    NSLog(@"%@", [self description]);
}

#pragma mark - Overrides for NSSet usage

- (NSUInteger)hash
{
    return self.chromosome.hash;
}

- (BOOL)isEqual:(id)object
{
    if (!object)
        return NO;
    
    if (![object isKindOfClass:[JAS8QueensSolution class]])
        return NO;
    
    JAS8QueensSolution *other = object;
    return [self.chromosome isEqual:other.chromosome];
}

@end
