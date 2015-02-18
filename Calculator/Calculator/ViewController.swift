//
//  ViewController.swift
//  Calculator
//
//  Created by scharkin on 1/31/15.
//  Copyright (c) 2015 Fun with Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!

    var userIsInTheMiddleOfTypingANumber = false
    var operandStack = Array<Double>()

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if let text = history.text {
            history.text = text + digit
        } else {
            history.text = digit
        }
        if legalDigit(digit) {
            if userIsInTheMiddleOfTypingANumber {
                display.text = display.text! + digit
            } else {
                display.text = digit
                userIsInTheMiddleOfTypingANumber = true
            }
        }
    }

    func legalDigit(digit: String) ->Bool {
        return digit != "." || display.text?.rangeOfString(".") == nil
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let value = displayValue {
            operandStack.append(value)
        }
        if let historyLine = history.text {
            if !historyLine.hasSuffix("=") {
                history.text = historyLine + "="
            }
        }
        println("operandStack = \(operandStack)")
    }
    
    var displayValue: Double? {
        get {
            if let text = display.text {
                if let number = NSNumberFormatter().numberFromString(text) {
                    return number.doubleValue
                }
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text = "\(value)"
            } else {
                display.text = "0"
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }

    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        history.text = history.text == nil ? operation : history.text! + operation
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        switch (operation) {
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "sin": performOperation { sin($0) }
        case "cos": performOperation { cos($0) }
        case "π": performConstant(M_PI)
        case "√": performOperation { sqrt($0) }
        case "±": performNegate()
        default: break
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }

    func performOperation(operation: (Double) -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    func performConstant(value: Double) {
        displayValue = value
        enter()
    }

    func performNegate() {
        if userIsInTheMiddleOfTypingANumber {
            if let value = displayValue {
                displayValue = -value
            }
        } else {
            performOperation { -$0 }
        }
    }
    
    @IBAction func clear() {
        operandStack.removeAll(keepCapacity: false)
        userIsInTheMiddleOfTypingANumber = false
        displayValue = nil
        history.text = nil
    }

    @IBAction func backspase() {
        if userIsInTheMiddleOfTypingANumber {
            if let text = display.text {
                if countElements(text) > 0 {
                    display.text = dropLast(display.text!)
                    history.text = dropLast(history.text!)
                }
            }
        }
    }
    
}

