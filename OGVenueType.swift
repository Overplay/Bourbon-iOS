//
//  OGVenueType.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/11/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

/// Identifies the type of venues to associate with the table.
///
/// - ALL: all venues
/// - MINE: only venues associated with the current user (owned and managed)
/// - OWNED: only the venues the current user owns
/// - MANAGED: only the venues the current user manages
enum OGVenueType {
    case ALL, MINE, OWNED, MANAGED
}
