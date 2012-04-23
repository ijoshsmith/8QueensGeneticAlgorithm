//
//  JAS8QueensChromosome.m
//  EightQueensAlgo
//
//  Created by Josh Smith on 4/10/12.
//  Copyright (c) 2012 iJoshSmith. All rights reserved.
//

#import "JAS8QueensChromosome.h"

@interface JAS8QueensChromosome ()
{
    NSNumber *fitnessCache;
    NSNumber *hasDuplicateGenesCache;
    NSNumber *normalizedHashCache;
}

@property (nonatomic, strong)   NSMutableString *genes;
@property (nonatomic, readonly) BOOL             hasDuplicateGenes;
@property (nonatomic, readonly) NSUInteger       normalizedHash;

- (BOOL)areEmptyThreats:(NSString *)threats;
- (NSInteger)fitnessOfGeneAtIndex:(NSUInteger)geneIndex;
- (BOOL)isFitInNorthForGene:(unichar)gene;
- (BOOL)isFitInNortheastForGene:(unichar)gene;
- (BOOL)isFitInEastForGene:(unichar)gene;
- (BOOL)isFitInSoutheastForGene:(unichar)gene;

@end


@implementation JAS8QueensChromosome

#pragma mark - Properties

@synthesize genes;

@dynamic geneSequence;
- (NSString *)geneSequence
{
    return self.genes;
}

@dynamic hasPerfectFitness;
- (BOOL)hasPerfectFitness
{
    return self.fitness == 0;
}

@dynamic hasDuplicateGenes;
- (BOOL)hasDuplicateGenes
{
    if (!hasDuplicateGenesCache)
    {
        BOOL result = NO;
        NSUInteger length = self.genes.length;
        for (NSUInteger i = 0; i < length && !result; ++i) 
        {
            unichar gene = [self.genes characterAtIndex:i];
            for (NSUInteger j = 0; j < length && !result; ++j) 
            {
                if (i != j)
                {
                    unichar otherGene = [self.genes characterAtIndex:j];
                    if (gene == otherGene)
                    {
                        result = YES;
                    }
                }
            }
        }
        hasDuplicateGenesCache = [NSNumber numberWithBool:result];
    }
    return [hasDuplicateGenesCache boolValue];
}

@dynamic hasValidGenes;
- (BOOL)hasValidGenes
{
    return !self.hasDuplicateGenes;
}

@dynamic fitness;
- (NSInteger)fitness
{
    if (!fitnessCache)
    {
        // Aggregate the fitness of every gene.
        NSInteger overallFitness = 0, geneFitness = 0;
        for (NSUInteger geneIndex = 0; 
             geneIndex < self.genes.length; 
             geneIndex++) 
        {
            geneFitness = [self fitnessOfGeneAtIndex:geneIndex];
            overallFitness += geneFitness;
        }
        
        fitnessCache = [NSNumber numberWithInteger:overallFitness];
    }
    return [fitnessCache integerValue];
}

@dynamic normalizedHash;
- (NSUInteger)normalizedHash
{
   /* 
    A string's hash is always the same for a given sequence of characters in 
    a particular order. Since we want to consider a given set of characters 
    to be the same, regardless of their order, we must sort the string's 
    characters and then recombine them into a new, sorted string. Once we 
    have that sorted string, we cache its hash value to avoid recalculating it.
    */
    if (!normalizedHashCache)
    {
        NSUInteger length = self.genes.length;
        NSMutableArray *geneBoxes = [NSMutableArray arrayWithCapacity:length];
        for (NSUInteger i = 0; i < self.genes.length; ++i) 
        {
            unichar gene = [self.genes characterAtIndex:i];
            NSNumber *geneBox = [NSNumber numberWithChar:gene];
            [geneBoxes addObject:geneBox];
        }
        [geneBoxes sortUsingSelector:@selector(compare:)];
        NSMutableString *sorted = [NSMutableString stringWithCapacity:length];
        for (NSNumber *geneBox in geneBoxes) 
        {
            unichar gene = [geneBox charValue];
            [sorted appendFormat:@"%c", gene];
        }
        NSUInteger result = [sorted hash];
        normalizedHashCache = [NSNumber numberWithUnsignedInteger:result];
    }
    return [normalizedHashCache unsignedIntegerValue];
}

#pragma mark - Overrides for NSSet usage

/* 
 Chromosomes are placed into NSMutableSets to ensure that the 
 population does not contain duplicate gene sequences, thus 
 maximizing genetic variety. The position of genes in a gene 
 sequence does not affect/alter the solution encoded by the 
 chromosome. Steps are taken to ensure that a chromosome is 
 considered to be equal/equivalent to another chromosome if 
 both of their gene sequences contain exactly the same genes, 
 regardless of the gene order.
 */

- (NSUInteger)hash
{
    return self.normalizedHash;
}

- (BOOL)isEqual:(id)object
{
    if (!object)
        return NO;
    
    if (![object isKindOfClass:[JAS8QueensChromosome class]])
        return NO;
    
    JAS8QueensChromosome *other = object;
    return self.normalizedHash == other.normalizedHash;
}

#pragma mark - Initializers

- (id)initWithGeneSequence:(NSString *)sequence
{
    self = [super init];
    if (self)
    {
        self.genes = [NSMutableString stringWithString:sequence];
    }
    return self;
}

- (id)initWithRandomGeneSequence
{
    NSMutableString *randomGenes = [NSMutableString stringWithCapacity:GENE_COUNT];
    for (int i = 0; i < GENE_COUNT; ++i)
    {
        [randomGenes appendString:RANDOM_GENE_STRING()];
    }
    return [self initWithGeneSequence:randomGenes];
}

#pragma mark - Interface

- (NSComparisonResult)compareFitnessWithChromosome:(JAS8QueensChromosome *)other
{
    // Zero is perfect fitness, lower numbers represent less fit chromosomes.
    NSInteger mine = self.fitness;
    NSInteger theirs = other.fitness;
    if      (mine < theirs) return NSOrderedDescending;
    else if (mine > theirs) return NSOrderedAscending;
    else                    return NSOrderedSame;
}

- (JAS8QueensChromosome *)mateWithChromosome:(JAS8QueensChromosome *)other
{
    NSMutableString *childSequence = nil;
    
    // Combine the genes of the two parents to form the child's gene sequence.
    NSUInteger crossoverAt = MAX(MIN(RANDOM_MOD(self.genes.length), 5), 3);
    NSString *mine = [self.genes substringToIndex:crossoverAt];
    NSString *theirs = [other.genes substringFromIndex:crossoverAt];
    childSequence = [NSMutableString stringWithFormat:@"%@%@", mine, theirs];
    
    // Mutate the child's genes sometimes.
    BOOL mutate = RANDOM() < MUTATION_THRESHOLD;
    if (mutate)
    {
        NSString *mutantGene = RANDOM_GENE_STRING();
        NSUInteger mutateAt = RANDOM_MOD(childSequence.length);
        NSRange mutantRange = (NSRange){mutateAt, 1};
        [childSequence replaceCharactersInRange:mutantRange 
                                     withString:mutantGene];
    }
    
    return [[JAS8QueensChromosome alloc] initWithGeneSequence:childSequence];
}

#pragma mark - Gene fitness function

- (NSInteger)fitnessOfGeneAtIndex:(NSUInteger)geneIndex
{
    // Return 0 if the gene represents a safe queen.
    NSInteger result = 0;
    
    unichar gene = [self.genes characterAtIndex:geneIndex];
    
    if (![self isFitInNorthForGene:gene])
        --result;
    
    if (![self isFitInNortheastForGene:gene])
        --result;
    
    if (![self isFitInEastForGene:gene])
        --result;
    
    if (![self isFitInSoutheastForGene:gene])
        --result;
    
    return result;
}

- (BOOL)areEmptyThreats:(NSString *)threats
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:threats];
    NSRange range = [self.genes rangeOfCharacterFromSet:set];
    return range.location == NSNotFound;
}

- (BOOL)isFitInNorthForGene:(unichar)gene
{
    NSMutableString *threats = [NSMutableString stringWithCapacity:4];
    for (int threat = gene - COLUMN_COUNT; 
         threat >= FIRST_GENE; 
         threat -= COLUMN_COUNT) 
    {
        [threats appendFormat:@"%c", threat];
    }
    return [self areEmptyThreats:threats];
}

- (BOOL)isFitInEastForGene:(unichar)gene
{
    NSMutableString *threats = [NSMutableString stringWithCapacity:4];
    for (int threat = gene + 1; 
         (threat - FIRST_GENE) % COLUMN_COUNT; 
         threat++) 
    {
        [threats appendFormat:@"%c", threat];
    }
    return [self areEmptyThreats:threats];
}

#define IS_ON_RIGHT_EDGE(__GENE) ((__GENE - FIRST_GENE) % COLUMN_COUNT == (COLUMN_COUNT - 1))

- (BOOL)isFitInNortheastForGene:(unichar)gene
{
    if (IS_ON_RIGHT_EDGE(gene))
        return YES;
    
    NSMutableString *threats = [NSMutableString stringWithCapacity:4];
    for (int threat = gene - (COLUMN_COUNT - 1); 
         threat > FIRST_GENE;
         threat -= COLUMN_COUNT - 1)
    {
        [threats appendFormat:@"%c", threat];
        
        if (IS_ON_RIGHT_EDGE(threat))
            break;
    }
    return [self areEmptyThreats:threats];
}

- (BOOL)isFitInSoutheastForGene:(unichar)gene
{
    if (IS_ON_RIGHT_EDGE(gene))
        return YES;
    
    NSMutableString *threats = [NSMutableString stringWithCapacity:4];
    for (int threat = gene + (COLUMN_COUNT + 1); 
         threat <= LAST_GENE;
         threat += COLUMN_COUNT + 1) 
    {
        [threats appendFormat:@"%c", threat];
        
        if (IS_ON_RIGHT_EDGE(threat))
            break;
    }
    return [self areEmptyThreats:threats];
}

@end
