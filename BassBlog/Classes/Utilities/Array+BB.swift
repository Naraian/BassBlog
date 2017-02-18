//
//  Array+BB.swift
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 4/26/16.
//  Copyright © 2016 BassBlog. All rights reserved.
//

import UIKit

extension RangeReplaceableCollection where Iterator.Element : Equatable
{
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(_ object : Iterator.Element)
    {
        if let index = self.index(of: object)
        {
            self.remove(at: index)
        }
    }
}
