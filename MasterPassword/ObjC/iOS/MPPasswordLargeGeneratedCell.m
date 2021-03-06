/**
 * Copyright Maarten Billemont (http://www.lhunath.com, lhunath@lyndir.com)
 *
 * See the enclosed file LICENSE for license information (LGPLv3). If you did
 * not receive this file, see http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * @author   Maarten Billemont <lhunath@lyndir.com>
 * @license  http://www.gnu.org/licenses/lgpl-3.0.txt
 */

//
//  MPPasswordLargeGeneratedCell.h
//  MPPasswordLargeGeneratedCell
//
//  Created by lhunath on 2014-03-19.
//  Copyright, lhunath (Maarten Billemont) 2014. All rights reserved.
//

#import "MPPasswordLargeGeneratedCell.h"
#import "MPiOSAppDelegate.h"
#import "MPAppDelegate_Store.h"
#import "MPPasswordTypesCell.h"

@implementation MPPasswordLargeGeneratedCell

- (void)awakeFromNib {

    [super awakeFromNib];

    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc]
            initWithTarget:self action:@selector(doResetCounterRecognizer:)];
    [self.counterButton addGestureRecognizer:gestureRecognizer];
}

- (void)updateWithElement:(MPElementEntity *)mainElement {

    [super updateWithElement:mainElement];

    MPElementGeneratedEntity *generatedElement = [self generatedElement:mainElement];
    if (generatedElement)
        self.counterLabel.text = strf( @"%lu", (unsigned long)generatedElement.counter );
    else
        self.counterLabel.text = @"1";

    if (!mainElement || mainElement.requiresExplicitMigration) {
        self.counterLabel.alpha = 0;
        self.counterButton.alpha = 0;
    }
    else {
        self.counterLabel.alpha = 1;
        self.counterButton.alpha = 1;
    }
}

- (void)resolveContentOfCellTypeForTransientSite:(NSString *)siteName usingKey:(MPKey *)key result:(void (^)(NSString *))resultBlock {

    PearlNotMainQueue( ^{
        resultBlock( [MPAlgorithmDefault generateContentNamed:siteName ofType:self.type withCounter:1 usingKey:key] );
    } );
}

- (void)resolveContentOfCellTypeForElement:(MPElementEntity *)element usingKey:(MPKey *)key result:(void (^)(NSString *))resultBlock {

    id<MPAlgorithm> algorithm = element.algorithm;
    NSString *siteName = element.name;

    PearlNotMainQueue( ^{
        resultBlock( [algorithm generateContentNamed:siteName ofType:self.type withCounter:1 usingKey:key] );
    } );
}

- (MPElementEntity *)saveContentTypeWithElement:(MPElementEntity *)element saveInContext:(NSManagedObjectContext *)context {

    element = [super saveContentTypeWithElement:element saveInContext:context];

    MPElementGeneratedEntity *generatedElement = [self generatedElement:element];
    if (generatedElement) {
        generatedElement.counter = [self.counterLabel.text intValue];
        [context saveToStore];
    }

    return element;
}

#pragma mark - Actions

- (IBAction)doIncrementCounter:(UIButton *)sender {

    [MPiOSAppDelegate managedObjectContextPerformBlock:^(NSManagedObjectContext *context) {
        MPElementGeneratedEntity *generatedElement = [self generatedElementInContext:context];
        if (!generatedElement)
            return;

        ++generatedElement.counter;
        [context saveToStore];

        PearlMainQueue( ^{
            [self updateAnimated:YES];
            [PearlOverlay showTemporaryOverlayWithTitle:@"Counter Incremented" dismissAfter:2];
        } );
    }];
}

- (void)doResetCounterRecognizer:(UILongPressGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;

    [MPiOSAppDelegate managedObjectContextPerformBlock:^(NSManagedObjectContext *context) {
        MPElementGeneratedEntity *generatedElement = [self generatedElementInContext:context];
        if (!generatedElement)
            return;

        generatedElement.counter = 1;
        [context saveToStore];

        PearlMainQueue( ^{
            [self updateAnimated:YES];
            [PearlOverlay showTemporaryOverlayWithTitle:@"Counter Reset" dismissAfter:2];
        } );
    }];
}

#pragma mark - Properties

- (MPElementGeneratedEntity *)generatedElementInContext:(NSManagedObjectContext *)context {

    return [self generatedElement:[[MPPasswordTypesCell findAsSuperviewOf:self] elementInContext:context]];
}

- (MPElementGeneratedEntity *)generatedElement:(MPElementEntity *)element {

    if (![element isKindOfClass:[MPElementGeneratedEntity class]])
        return nil;

    return (MPElementGeneratedEntity *)element;
}

@end
