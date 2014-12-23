//
//  Queue.swift
//  Pelorus
//
//  Created by Will Charczuk on 12/23/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import Foundation

class FixedQueue<T> {
    
    typealias Element = T
    
    private var _queue = Array<T>()
    
    init() {}
    init(maxLength: Int?) {
        _maxLength = maxLength
    }
    init(maxLength: Int?, values: Array<T>) {
        _queue = values
        _maxLength = maxLength
    }
    
    func Enqueue(val: T) {
        _queue.append(val)
        Resize()
    }
    
    func Dequeue() -> T? {
        let val = _queue.first
        
        if nil != val {
            _queue.removeAtIndex(0)
        }
        
        return val
    }
    
    func Peek() -> T? {
        return _queue.first
    }
    
    var Length : Int {
        get {
            return _queue.count
        }
    }
    
    func Filter(predicate: (T) -> Bool) -> FixedQueue<T> {
        var filtered = Array<T>()
        
        var test_filtered = _queue.filter {(val) -> Bool in nil != val}
        
        for value : T in _queue {
            if predicate(value) {
                filtered.append(value)
            }
        }
        
        return FixedQueue<T>(maxLength: self._maxLength, values: filtered)
    }
    
    func Transform<F>(transform: (T) -> (F)) -> FixedQueue<F> {
        var transformed = Array<F>()
        
        for value in _queue {
            transformed.append(transform(value))
        }
        
        return FixedQueue<F>(maxLength: self._maxLength, values: transformed)
    }
    
    func Reduce<F>(reduction: (F?, T) -> F?) -> F? {
        var reduced : F? = nil
        
        for value in _queue {
            reduced = reduction(reduced, value)
        }
        
        return reduced
    }
    
    func Reverse() -> FixedQueue<T> {
        return FixedQueue<T>(maxLength: _maxLength, values: _queue.reverse())
    }
    
    subscript(index: Int) -> T {
        return _queue[index]
    }
    
    var _maxLength : Int? = nil
    var MaxLength : Int? {
        get {
            return _maxLength
        }
        set(value) {
            _maxLength = value
            Resize()
        }
    }
    
    func Resize() {
        if nil != _maxLength {
            if _queue.count > _maxLength! {
                let numberToRemove = _queue.count - _maxLength!
                for i in 1 ... numberToRemove {
                    _queue.removeAtIndex(0)
                }
            }
        }
    }
}