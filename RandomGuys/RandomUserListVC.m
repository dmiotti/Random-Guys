//
//  ViewController.m
//  RandomGuys
//
//  Created by David Miotti on 27/12/2016.
//  Copyright © 2016 David Miotti. All rights reserved.
//

#import "RandomUserListVC.h"
#import "Models.h"
#import "CoreDataStack.h"
#import "FetchRemoteRandomUsers.h"
#import "RandomUserDetailVC.h"
#import <Masonry/Masonry.h>

/// List all Users in a tableView
@interface RandomUserListVC ()<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RandomUserListVC

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Random Guys", @"");
    self.downloadQueue = [[NSOperationQueue alloc] init];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self downloadNewRandomUser];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (IBAction)tappedAddBtn:(id)sender {
    [self downloadNewRandomUser];
}

- (void)downloadNewRandomUser {
    [self showDownloadState];
    FetchRemoteRandomUsers *downloadOperation = [[FetchRemoteRandomUsers alloc] init];
    __weak FetchRemoteRandomUsers *weakOperation = downloadOperation;
    __weak RandomUserListVC *weakSelf = self;
    downloadOperation.completionBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideDownloadState];
            NSError *err = [weakOperation error];
            if (err != nil) {
                [weakSelf showError:err];
            }
        });
    };
    [self.downloadQueue addOperation:downloadOperation];
}

- (void)showError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[error localizedDescription]
                                                                   message:[error localizedRecoverySuggestion]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"RandomUserDetailsShow"]) {
        UIViewController *destination = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        RandomUser *ru = [_fetchedResultsController objectAtIndexPath:indexPath];
        RandomUserDetailVC *dest = (RandomUserDetailVC *)destination;
        dest.randomUser = ru;
    }
}

#pragma mark - Loading state

- (void)showDownloadState {
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loading startAnimating];
    [loading sizeToFit];
    UIBarButtonItem *loadingBbi = [[UIBarButtonItem alloc] initWithCustomView:loading];
    [self.navigationItem setRightBarButtonItem:loadingBbi animated:YES];
}

- (void)hideDownloadState {
    UIBarButtonItem *addBbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(tappedAddBtn:)];
    [self.navigationItem setRightBarButtonItem:addBbi animated:YES];
}

#pragma mark - NSNotification

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self downloadNewRandomUser];
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext* managedObjectContext = [[[CoreDataStack sharedInstance] persistentContainer] viewContext];
    
    NSFetchRequest *fetchRequest = [RandomUser fetchRequest];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"importedDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RandomUserCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RandomUser *user = [_fetchedResultsController objectAtIndexPath:indexPath];
        NSManagedObjectContext *context = [[CoreDataStack sharedInstance] viewContext];
        [context deleteObject:user];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RandomUser *user = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [user email];
    NSString *fullName = [@[[user firstname], [user lastname]] componentsJoinedByString:@" "];
    cell.detailTextLabel.text = fullName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
