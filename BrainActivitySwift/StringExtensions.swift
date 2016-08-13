//
//  StringExtensions.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 13/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//
enum SessionFileType : String {
    case Data = "_data"
}
extension String {
    func fileNameForSessionFile(type : SessionFileType,postfix : String) -> String {
        return "\(self)\(type.rawValue)\(postfix)"
    }
}
