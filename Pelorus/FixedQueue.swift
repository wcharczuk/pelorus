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
    
    fileprivate var _queue = Array<T>()
    
    init() {}
    init(maxLength: Int?) {
        _maxLength = maxLength
    }
    init(maxLength: Int?, values: Array<T>) {
        _queue = values
        _maxLength = maxLength
    }
    
    func Enqueue(_ val: T) {
        _queue.append(val)
        Resize()
    }
    
    func Dequeue() -> T? {
        let val = _queue.first
        
        if nil != val {
            _queue.remove(at: 0)
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
    
    func Filter(_ predicate: (T) -> Bool) -> FixedQueue<T> {
        var filtered = Array<T>()
        
        for value : T in _queue {
            if predicate(value) {
                filtered.append(value)
            }
        }
        
        return FixedQueue<T>(maxLength: self._maxLength, values: filtered)
    }
    
    func Transform<F>(_ transform: (T) -> (F)) -> FixedQueue<F> {
        var transformed = Array<F>()
        
        for value in _queue {
            transformed.append(transform(value))
        }
        
        return FixedQueue<F>(maxLength: self._maxLength, values: transformed)
    }
    
    func Reduce<F>(_ reduction: (F?, T) -> F?) -> F? {
        var reduced : F? = nil
        
        for value in _queue {
            reduced = reduction(reduced, value)
        }
        
        return reduced
    }
    
    func Reverse() -> FixedQueue<T> {
        return FixedQueue<T>(maxLength: _maxLength, values: _queue.reversed())
    }
    
    func ToList() -> Array<T> {
        var list = Array<T>()
        for elem in _queue {
            list.append(elem)
        }
        return list
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
                for _ in 1 ... numberToRemove {
                    _queue.remove(at: 0)
                }
            }
        }
    }
}
