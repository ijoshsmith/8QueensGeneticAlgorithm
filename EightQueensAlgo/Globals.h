//
//  Globals.h
//  EightQueensAlgo
//
//  Created by Josh Smith on 4/10/12.
//  Copyright (c) 2012 iJoshSmith. All rights reserved.
//

/*** SHARED CONSTANTS ***/
#define GENE_COUNT           (8)
#define COLUMN_COUNT         (8)
#define ROW_COUNT            (8)
#define MAX_GENE_VALUE       (COLUMN_COUNT * ROW_COUNT)
#define FIRST_GENE           (48)  // '0'
#define LAST_GENE            (112) // 'p'

/*** SHARED MACROS ***/
#define RANDOM()             (arc4random())
#define RANDOM_MOD(__MOD)    (arc4random_uniform(__MOD))
#define RANDOM_GENE_STRING() ([NSString stringWithFormat:@"%c", FIRST_GENE + RANDOM_MOD(MAX_GENE_VALUE)])


/*** ALGORITHM CONSTANTS ***/
#define ELITE_PERCENT        (0.13)
#define SLUM_PERCENT         (0.02)
#define POPULATION_SIZE      (2000)
#define MAX_GENERATIONS      (1000)
#define STAGNATION_THRESHOLD (25)


/*** CHROMOSOME CONSTANTS ***/
#define ARC4RANDOM_MAX     (0x100000000)                    // The highest value returned by arc4random()
#define MUTATION_RATE	   (0.35f)                          // Mutate a child chromosome's genes about 35% of the time.
#define MUTATION_THRESHOLD (ARC4RANDOM_MAX * MUTATION_RATE) // This is used to determine if a mutation should occur.
