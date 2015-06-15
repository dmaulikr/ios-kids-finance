//
//  DatabaseController.m
//  KidsFinance
//
//  Created by Rene Argento on 3/31/15.
//  Copyright (c) 2015 Umbrella. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Enumerations.h"
#import "DAO.h"

@interface DAO ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation DAO

-(id)init{
    if (self = [super init]) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = appDelegate.managedObjectContext;
    }
    
    return self;
}

- (BOOL)saveTransaction:(Transactions*) transaction{
    //Entity for table Transactions
    NSEntityDescription *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Transactions" inManagedObjectContext:self.managedObjectContext];
    //Set values to be stored in the database
    [entity setValue:transaction.value forKey:@"value"];
    [entity setValue:transaction.date forKey:@"date"];
    [entity setValue:[NSNumber numberWithLong:transaction.category] forKey:@"category"];
    [entity setValue:[NSNumber numberWithBool:transaction.isEarning] forKey:@"isEarning"];
    
    NSError *error;
    //Returns true if the data was stored succesfully in the database
    BOOL isSaved = [self.managedObjectContext save:&error];
    
    NSLog(@"Values stored succesfully in the database: %d", isSaved);
    return isSaved;
}

- (NSMutableArray*)getData:(NSDate*)initialDate withFinalDate:(NSDate*)endDate {
    //Creating entity object for table Transactions
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transactions" inManagedObjectContext:self.managedObjectContext];
    
    //Create fetch request
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    if (initialDate != nil && endDate != nil) {
        NSLog(@"%@",initialDate);
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"date >= %@ && date <= %@", initialDate, endDate];
        [fetchRequest setPredicate:predicate];
    } else if (initialDate != nil && endDate == nil) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"date >= %@", initialDate];
        [fetchRequest setPredicate:predicate];
    } else if (initialDate == nil && endDate != nil) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"date <= %@", endDate];
        [fetchRequest setPredicate:predicate];
    }
    
    NSSortDescriptor *sortDescriptorByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorByDate, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //Get all rows
    NSMutableArray * values = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];

    //Core data returns each row as managed objects so we can access rows values through key-value pair
    for(NSManagedObject *row in values) {
        NSLog(@"Value: %@  -  Category: %@ -  earning: %@\n", [row valueForKey:@"value"], [row valueForKey:@"category"], [row valueForKey:@"isEarning"]);
    }
    
    return values;
}

-(BOOL)updateTransaction:(NSManagedObject *)transaction withDictionary:(NSDictionary *)dictionary {
    
    return YES;
}

-(BOOL)deleteTransaction:(NSManagedObject *) transaction {
    BOOL result;
    NSError *error = nil;
    
    [self.managedObjectContext deleteObject:transaction];
    
    if (![self.managedObjectContext save:&error]) {
        result = NO;
    } else {
        result = YES;
    }
    
    NSLog(@"Delete transaction: %d", result);
    return result;
}



@end