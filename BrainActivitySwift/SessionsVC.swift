//
//  SessionsVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 04/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit

class SessionsVC : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        let accordion = AccordionView(frame: CGRectMake(0,70,width,height))
        self.view.addSubview(accordion)
        let header = SessionHeaderView(dateLabel: "Tuesday",moodLabel: "zxczcx")
        let section = SessionsContainerView(containerWidth: width)
        accordion.addHeader(header, withView: section)
        accordion.setNeedsLayout()
        accordion.allowsMultipleSelection = true
        accordion.allowsEmptySelection = true
    }
}
