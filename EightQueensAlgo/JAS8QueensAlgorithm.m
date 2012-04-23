//
//  JASEightQueensAlgo.m
//  EightQueensAlgo
//
//  Created by Josh Smith on 4/10/12.
//  Copyright (c) 2012 iJoshSmith. All rights reserved.
//

#import "JAS8QueensAlgorithm.h"
#import "JAS8QueensChromosome.h"
#import "JAS8QueensSolution.h"

@interface JAS8QueensAlgorithm ()
{
    NSUInteger generation;
}

// Add private setter
@property (nonatomic, readwrite, strong) NSMutableSet *solutions;

// Private properties
@property (nonatomic, strong) NSMutableArray *population;

// Private methods
- (void)analyzePopulation;
- (void)breedNextGeneration;
- (NSSet *)findPerfectChromosomes;
- (void)populate;
- (void)printBestChromosome;
- (void)replaceStagnantPopulation;
- (void)run;
- (NSArray *)selectBreeders;

@end


@implementation JAS8QueensAlgorithm

#pragma mark - Properties

@synthesize population, solutions;

#pragma mark - Interface

- (id)init
{
    self = [super init];
    if (self)
    {
        self.solutions = [NSMutableSet set];
        self.population = [NSMutableArray arrayWithCapacity:POPULATION_SIZE];
    }
    return self;
}

- (void)execute
{
    [self populate];
    [self run];
}

#pragma mark - Private methods

- (void)populate
{
    JAS8QueensChromosome *chromo;
    NSMutableSet *uniqueChromos = [NSMutableSet setWithCapacity:POPULATION_SIZE];
    do
    {
        chromo = [[JAS8QueensChromosome alloc] initWithRandomGeneSequence];
        if (chromo.hasValidGenes)
        {
            [uniqueChromos addObject:chromo];
        }
    } while (uniqueChromos.count < POPULATION_SIZE);
    
    [self.population addObjectsFromArray:uniqueChromos.allObjects];
}

- (void)run
{
    for (generation = 1; 
         generation <= MAX_GENERATIONS && !self.solutions.count; 
         generation++)
    {
        [self analyzePopulation];
        [self printBestChromosome];
        [self replaceStagnantPopulation];
        [self breedNextGeneration];
    }
}

- (void)analyzePopulation
{
    NSSet *perfectChromosomes = [self findPerfectChromosomes];
    if (perfectChromosomes.count)
    {
        JAS8QueensSolution *solution;
        for (JAS8QueensChromosome *chromo in perfectChromosomes) 
        {
            solution = [[JAS8QueensSolution alloc] initWithChromosome:chromo 
                                                       fromGeneration:generation];
            [self.solutions addObject:solution];
        }
    }
}

- (NSSet *)findPerfectChromosomes
{
    NSMutableSet *result = [NSMutableSet setWithCapacity:1];
    for (JAS8QueensChromosome *chromo in self.population) 
    {
        if (chromo.hasPerfectFitness)
        {
            [result addObject:chromo];
        }
    }
    return result;
}

- (void)printBestChromosome
{
    JAS8QueensChromosome *best = nil;
    for (JAS8QueensChromosome *chromo in self.population) 
    {
        if (!best || chromo.fitness > best.fitness)
        {
            best = chromo;
        }
    }
    NSLog(@"Best fitness for generation #%ld: %ld   gene sequence: %@", generation, best.fitness, best.geneSequence);
}

- (void)replaceStagnantPopulation
{
    BOOL stagnant = generation % STAGNATION_THRESHOLD == 0;
    if (stagnant)
    {
        [self.population removeAllObjects];
        [self populate];
    }
}

- (void)breedNextGeneration
{
    // Use a set for storing the children 
    // to avoid duplicate gene sequences in the
    // next generation. This relies on the chromosome's 
    // overridden isEqual: and hash implementation.
    NSMutableSet *uniqueChildren = [NSMutableSet setWithCapacity:POPULATION_SIZE];
    NSArray *breeders = [self selectBreeders];
    NSUInteger breeder1Index, breeder2Index, breederCount = breeders.count;
    JAS8QueensChromosome *breeder1, *breeder2, *child; 
    do
    {
        breeder1Index = RANDOM_MOD(breederCount);
        breeder2Index = RANDOM_MOD(breederCount);
        if (breeder1Index != breeder2Index)
        {
            breeder1 = [breeders objectAtIndex:breeder1Index];
            breeder2 = [breeders objectAtIndex:breeder2Index];
            child = [breeder1 mateWithChromosome:breeder2];
            if (child.hasValidGenes)
                [uniqueChildren addObject:child];
        }
    } while (uniqueChildren.count < POPULATION_SIZE);
    
    [self.population removeAllObjects];
    [self.population addObjectsFromArray:uniqueChildren.allObjects];
}

- (NSArray *)selectBreeders
{
    // Sort the chromosomes by fitness.
    SEL sorter = @selector(compareFitnessWithChromosome:);
    NSArray *sortedChromos = [self.population sortedArrayUsingSelector:sorter];
    
    // Single out the best of the chromosomes for mating.
    NSUInteger eliteCount = POPULATION_SIZE * ELITE_PERCENT;
    
    // Add in some of the non-elite to keep the gene pool diverse.
    NSUInteger breederCount = POPULATION_SIZE * (ELITE_PERCENT + SLUM_PERCENT);
    
    NSMutableSet *uniqueBreeders = [NSMutableSet setWithCapacity:breederCount];
    
    // Add the elite/best chromosomes to the breeders list.
    NSRange range = (NSRange){0, eliteCount};
    NSIndexSet *eliteIndexes = [NSIndexSet indexSetWithIndexesInRange:range];
    NSArray *elite = [sortedChromos objectsAtIndexes:eliteIndexes];
    [uniqueBreeders addObjectsFromArray:elite];
    
    // Add in some non-elite (slum) chromosomes.
    NSUInteger minSlumIndex = eliteCount, slumIndex;
    JAS8QueensChromosome *slumChromo;
    do 
    {
        slumIndex = RANDOM_MOD(POPULATION_SIZE);
        if (minSlumIndex < slumIndex)
        {
            slumChromo = [sortedChromos objectAtIndex:slumIndex];
            [uniqueBreeders addObject:slumChromo];
        }
    } while (uniqueBreeders.count < breederCount);
    
    return uniqueBreeders.allObjects;
}

@end
