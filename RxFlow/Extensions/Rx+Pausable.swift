//
//  Rx+Pausable.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-10-01.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxSwift

// this code had been inspired by the project: https://github.com/RxSwiftCommunity/RxSwiftExt
// Its License can be found here: ../DependenciesLicenses/RxSwiftCommunity-RxSwiftExt-License

extension ObservableType {

    /// Pauses the elements of the source observable sequence based on the latest element from the second observable sequence.
    /// Elements are ignored unless the second sequence has most recently emitted `true`.
    /// seealso: [pausable operator on reactivex.io](http://reactivex.io/documentation/operators/backpressure.html)
    ///
    /// - Parameter pauser: The observable sequence used to pause the source observable sequence.
    /// - Returns: The observable sequence which is paused based upon the pauser observable sequence.
    public func pausable<P: ObservableType> (withPauser pauser: P) -> Observable<E> where P.E == Bool {

        return withLatestFrom(pauser) { element, paused in
            return (element, paused)
            }.filter { _, paused in
                paused
            }.map { element, _ in
                element
        }
    }

    /// Pauses the elements of the source observable sequence based on the latest element from the second observable sequence.
    /// The pause is available only after a certain count of events. Before the number of emitted events reaches that count
    /// the Pauser will not be taken care of. When the Pauser is active, elements are ignored unless the second sequence
    /// has most recently emitted `true`.
    /// seealso: [pausable operator on reactivex.io](http://reactivex.io/documentation/operators/backpressure.html)
    ///
    /// - Parameter count: the number of events before considering the pauser parameter
    /// - Parameter pauser: The observable sequence used to pause the source observable sequence.
    /// - Returns: The observable sequence which is paused based upon the pauser observable sequence.
    public func pausable<P: ObservableType> (afterCount count: Int, withPauser pauser: P) -> Observable<E> where P.E == Bool {

        return enumerated().flatMap({ (indexedValue) -> Observable<(Self.E, Int)> in
            let (index, value) = indexedValue
            return Observable.just((value, index))
        }).withLatestFrom(pauser) { element, paused in
            let (value, index) = element
            if index < count {
                print ("First step, no pause for value \(value)")
                return (value, true)
            }
            print ("Next step, pause is taken care of for value \(value)")
            return (value, paused)
            }.filter { _, paused in
                paused
            }.map { element, _ in
                element
        }
    }
}
