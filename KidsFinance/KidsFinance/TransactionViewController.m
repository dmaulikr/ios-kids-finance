//
//  TransationsViewController.m
//  KidsFinance
//
//  Created by Rafael  Letro on 31/03/15.
//  Copyright (c) 2015 Umbrella. All rights reserved.
//

#import "AppDelegate.h"
#import "TransactionViewController.h"
#import "Transactions.h"
#import "DAO.h"
#import "Utils.h"
#import "Constants.h"

@interface TransactionViewController ()
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionField;

@property (weak, nonatomic) IBOutlet UIDatePicker *dateTransationPicker;
@property AppDelegate * appDelegate;
@property (strong, nonatomic) Transactions * transactionsCurrent;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@end

@implementation TransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self.view setBackgroundColor: [UIColor colorWithRed:82.0/255.0 green:177.0/255.0 blue:193.0/255.0 alpha:1.0]];

    //add a tap gesture recognizer to capture all tap events
    //this will include tap events when a user clicks off of a textfield
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundTap:)];
    self.tapRecognizer.numberOfTapsRequired = 1;
    self.tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tapRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmTransationClicked:(id)sender {
    BOOL wasTransactionSuccessful;
    
    if ([self saveTransactionOnCoreData]) {
        wasTransactionSuccessful = YES;
        [Utils updateCurrentMoneyOnKeyChain:[self.valueField.text doubleValue] withIsAddMoney:self.isAddMoney];
    } else {
        wasTransactionSuccessful = NO;
    }
    
    [self showResultPopup:wasTransactionSuccessful];
    [self clearFields];
}

- (IBAction)cancelTransaction:(id)sender {
    if (self.isUpdate) {
        [self performSegueWithIdentifier:GO_TO_ACCOUNT_SEGUE sender:self];
    } else {
        [self performSegueWithIdentifier:GO_TO_HOME_SEGUE sender:self];
    }
}

- (BOOL)saveTransactionOnCoreData {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transactions" inManagedObjectContext:self.appDelegate.managedObjectContext];
    self.transactionsCurrent = [[Transactions alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    [self.transactionsCurrent setDescriptionTransaction: self.descriptionField.text ];
    [self.transactionsCurrent setValue: [NSNumber numberWithDouble:[self.valueField.text doubleValue]]];
    [self.transactionsCurrent setDate:self.dateTransationPicker.date];
    [self.transactionsCurrent setCategory: self.category];
    NSLog(@"%d",self.isAddMoney);
    [self.transactionsCurrent setIsEarning:self.isAddMoney];
    
    DAO * daoOperation = [[DAO alloc] init];
    return [daoOperation saveTransaction:self.transactionsCurrent];
}

- (void)showResultPopup:(BOOL) isSuccess{
    NSString *title;
    NSString *message;
    
    if(isSuccess) {
        title = @"Sucesso";
        message = @"Valores atualizados!";
    } else {
        title = @"Erro";
        message = @"Ocorreu um problema ao tentar atualizar os valores";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.isUpdate) {
        //TODO - call AccountViewController method
        //-(void)updateTransaction:(NSManagedObject *)transaction withDictionary:(NSDictionary *)dictionary {
        
        //[self updateTransaction: [self.values objectAtIndex:indexPath.row]];
        
    } else {
        [self performSegueWithIdentifier:@"homeSegue" sender:self];
    }
}

- (void)clearFields{
    self.valueField.text = @"";
    self.descriptionField.text = @"";
}


- (void)onBackgroundTap:(id)sender{
    //when the tap gesture recognizer gets an event, it calls endEditing on the view controller's view
    //this should dismiss the keyboard
    [[self view] endEditing:YES];
}




@end