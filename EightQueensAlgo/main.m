//
//  main.m
//  EightQueensAlgo
//
//  Created by Josh Smith on 4/10/12.
//  Copyright (c) 2012 iJoshSmith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JAS8QueensAlgorithm.h"
#import "JAS8QueensChromosome.h"

#define RUN_ONCE           (YES)
#define DISTINCT_SOLUTIONS (92) // http://en.wikipedia.org/wiki/8_queens#Solutions_to_the_eight_queens_puzzle

void runOnce();
void findAllDistinctSolutions();

int main(int argc, const char * argv[])
{
    @autoreleasepool 
    {
        if (RUN_ONCE)
        {
            runOnce();
        }
        else 
        {
            findAllDistinctSolutions();
        }
    }
    return 0;
}

void runOnce()
{
    NSLog(@"Searching for a solution...");
    JAS8QueensAlgorithm *algorithm = [[JAS8QueensAlgorithm alloc] init];
    [algorithm execute];
    [algorithm.solutions makeObjectsPerformSelector:@selector(printDescription)];
}

/* 
 This is definitely not the most efficient way to find all distinct solutions to
 the 8 Queens problem, but it simply proves that the algorithm works.
*/
void findAllDistinctSolutions()
{
    NSMutableSet *solutions = [NSMutableSet setWithCapacity:DISTINCT_SOLUTIONS];
    NSDate *startedAt = [NSDate date];
    int counter = 0;
    do 
    {    
        NSLog(@"Run #%d   Solutions: %ld", ++counter, solutions.count);
        JAS8QueensAlgorithm *algorithm = [[JAS8QueensAlgorithm alloc] init];
        [algorithm execute];
        [solutions addObjectsFromArray:algorithm.solutions.allObjects];
    } while (solutions.count < DISTINCT_SOLUTIONS);
    
    // Duration
    NSTimeInterval elapsed = [startedAt timeIntervalSinceNow] * -1;
    NSLog(@"Duration: %.2f seconds", elapsed);
    
    // Count
    NSLog(@"Distinct solutions found: %ld", solutions.count);
    
    // Average Generation
    NSArray *generations = [solutions valueForKey:@"generation"];
    __block int sum = 0;
    [generations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
     {
         sum += [((NSNumber *)obj) intValue];
     }];
    int average = sum / generations.count;
    NSLog(@"Average generation: %d", average);
    
    // Print a diagram of each solution to the console
    [solutions makeObjectsPerformSelector:@selector(printDescription)];
    
    // List all gene sequences
    NSArray *sequences = [solutions valueForKeyPath:@"chromosome.geneSequence"];
    NSMutableString *buffer = [NSMutableString stringWithCapacity:sequences.count * 8];
    for (NSString *sequence in sequences) 
    {
        [buffer appendFormat:@"%@\n", sequence];
    }
    NSLog(@"Gene sequences\n%@", buffer);
}
