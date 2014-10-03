//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Alexei Baboulevitch on 10/3/14.
//  Copyright (c) 2014 Alexei Baboulevitch. All rights reserved.
//

import UIKit

/*
This is a simple faux keyboard intended to debug issues with constraints and rotations, as well as
to compare performance between manual layout and autolayout.
*/

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!

    var usingConstraints: Bool = true
    var constraintsInitialized: Bool = false
    
    var heightConstraint: NSLayoutConstraint?
    
    var squares: [[UIView]] = []
    var xSpacers: [[UIView]] = []
    var ySpacers: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton.buttonWithType(.System) as UIButton
    
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    
        self.nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.nextKeyboardButton)
    
        var nextKeyboardButtonLeftSideConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
        var nextKeyboardButtonBottomConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraints([nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint])
        
        addSquareViews()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if self.usingConstraints {
            if !self.constraintsInitialized {
                self.addSquareConstraints()
                self.constraintsInitialized = true
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        if !self.usingConstraints {
            self.layoutSquares()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.setHeight(100)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if toInterfaceOrientation.isLandscape {
            self.setHeight(300)
        }
        else {
            self.setHeight(100)
        }
    }
    
    func setHeight(height: CGFloat) {
        if self.heightConstraint == nil {
            self.heightConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: height)
            self.view.addConstraint(self.heightConstraint!)
        }
        else {
            self.heightConstraint?.constant = height
        }
    }
    
    func addSquareViews() {
        for _ in 0..<4 {
            var ySpacer = UIView()
            ySpacer.backgroundColor = UIColor.redColor()
            self.view.addSubview(ySpacer)
            self.ySpacers.append(ySpacer)
            
            var squareRow: [UIView] = []
            var xSpacerRow: [UIView] = []
            
            for _ in 0..<5 {
                var xSpacer = UIView()
                xSpacer.backgroundColor = UIColor.greenColor()
                self.view.addSubview(xSpacer)
                xSpacerRow.append(xSpacer)
                
                var square = UIView()
                square.backgroundColor = UIColor.blueColor()
                self.view.addSubview(square)
                squareRow.append(square)
            }
            
            var xSpacer = UIView()
            xSpacer.backgroundColor = UIColor.greenColor()
            self.view.addSubview(xSpacer)
            xSpacerRow.append(xSpacer)
            
            self.squares.append(squareRow)
            self.xSpacers.append(xSpacerRow)
        }
        
        var ySpacer = UIView()
        ySpacer.backgroundColor = UIColor.redColor()
        self.view.addSubview(ySpacer)
        self.ySpacers.append(ySpacer)
    }
    
    var squareWidth: CGFloat = 0.15
    var squareHeight: CGFloat = 0.2
    
    func addSquareConstraints() {
        var views: [String:UIView] = [:]
        
        let populateViews = { (inout views: [String:UIView]) -> Void in
            for row in 0..<4 {
                var ySpacer = self.ySpacers[row]
                ySpacer.setTranslatesAutoresizingMaskIntoConstraints(false)
                views["ySpacer\(row)"] = ySpacer
                
                for col in 0..<5 {
                    var xSpacer = self.xSpacers[row][col]
                    xSpacer.setTranslatesAutoresizingMaskIntoConstraints(false)
                    views["xSpacer\(row)x\(col)"] = xSpacer
                    
                    var square = self.squares[row][col]
                    square.setTranslatesAutoresizingMaskIntoConstraints(false)
                    views["square\(row)x\(col)"] = square
                }
                
                var xSpacer = self.xSpacers[row][5]
                xSpacer.setTranslatesAutoresizingMaskIntoConstraints(false)
                views["xSpacer\(row)x5"] = xSpacer
            }
            
            var ySpacer = self.ySpacers[4]
            ySpacer.setTranslatesAutoresizingMaskIntoConstraints(false)
            views["ySpacer4"] = ySpacer
        }
        populateViews(&views)
        
        for (row, colArray) in enumerate(xSpacers) {
            let firstName = "xSpacer\(row)x0"
            for (col, spacer) in enumerate(colArray) {
                let name = "xSpacer\(row)x\(col)"
                if col == 0 {
                    let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[\(name)(10)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
                    self.view.addConstraints(vConstraints)
                }
                else {
                    let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[\(name)(\(firstName))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
                    let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[\(name)(\(firstName))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
                    self.view.addConstraints(hConstraints)
                    self.view.addConstraints(vConstraints)
                }
            }
        }

        for (row, spacer) in enumerate(ySpacers) {
            let name = "ySpacer\(row)"
            let firstName = "ySpacer0"
            if row == 0 {
                let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[\(name)(10)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
                self.view.addConstraints(vConstraints)
            }
            else {
                let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[\(name)(\(firstName))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
                let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[\(name)(\(firstName))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
                self.view.addConstraints(hConstraints)
                self.view.addConstraints(vConstraints)
            }
            
            let centerConstraint = NSLayoutConstraint(item: spacer, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: spacer.superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            self.view.addConstraint(centerConstraint)
        }
        
        for (row, colArray) in enumerate(squares) {
            let firstName = "square\(row)x0"
            for (col, square) in enumerate(colArray) {
                let name = "square\(row)x\(col)"

                if col == 0 {
                    let squareWidth = NSLayoutConstraint(item: square, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: square.superview, attribute: NSLayoutAttribute.Width, multiplier: self.squareWidth, constant: 0)
                    let squareHeight = NSLayoutConstraint(item: square, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: square.superview, attribute: NSLayoutAttribute.Height, multiplier: self.squareHeight, constant: 0)
                    self.view.addConstraint(squareWidth)
                    self.view.addConstraint(squareHeight)
                }
                else {
                    let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[\(name)(\(firstName))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
                    let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[\(name)(\(firstName))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
                    self.view.addConstraints(hConstraints)
                    self.view.addConstraints(vConstraints)
                }
            }
        }
        
        for row in 0..<4 {
            let constraints = NSLayoutConstraint.constraintsWithVisualFormat("|[xSpacer\(row)x0][square\(row)x0][xSpacer\(row)x1][square\(row)x1][xSpacer\(row)x2][square\(row)x2][xSpacer\(row)x3][square\(row)x3][xSpacer\(row)x4][square\(row)x4][xSpacer\(row)x5]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)
            self.view.addConstraints(constraints)
        }

        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[ySpacer0][square0x0][ySpacer1][square1x0][ySpacer2][square2x0][ySpacer3][square3x0][ySpacer4]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        self.view.addConstraints(constraints)
    }
    
    func layoutSquares() {
        let xSize: CGFloat = self.view.bounds.width * self.squareWidth
        let ySize: CGFloat = self.view.bounds.height * self.squareHeight
        let xGap: CGFloat = (self.view.bounds.width - (xSize * CGFloat(5))) / CGFloat(6)
        let yGap: CGFloat = (self.view.bounds.height - (ySize * CGFloat(4))) / CGFloat(5)
        
        for (row, colArray) in enumerate(self.squares) {
            for (col, square) in enumerate(colArray) {
                let x = xGap + CGFloat(col) * (xGap + xSize)
                let y = yGap + CGFloat(row) * (yGap + ySize)
                square.frame = CGRectMake(x, y, xSize, ySize)
            }
        }
    }
}
