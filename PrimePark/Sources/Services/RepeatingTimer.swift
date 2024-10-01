//
//  RepeatingTimer.swift
//  RepeatingTimer
//
//  Created by Vanjo Lutik on 17.11.2021.
//

import Foundation

class RepeatingTimer {

    private let timeInterval: TimeInterval
    private let workingQueue: DispatchQueue
    
    init(timeInterval: TimeInterval, workingQueue: DispatchQueue) {
        self.timeInterval = 1
        self.workingQueue = workingQueue
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource(queue: workingQueue)
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return timer
    }()

    var eventHandler: (() -> Void)?

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }

    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}
