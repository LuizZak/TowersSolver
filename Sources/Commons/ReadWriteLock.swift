#if os(Windows)

import WinSDK
import ucrt

public class ReadWriteLock {
    var lock: SRWLOCK
    
    public init() {
        lock = SRWLOCK()

        InitializeSRWLock(&lock)
    }

    public func lockingForRead<T>(_ block: () throws -> T) rethrows -> T {
        var l = lockForRead()
        defer { l.unlock() }
        
        return try block()
    }

    public func lockingForWrite<T>(_ block: () throws -> T) rethrows -> T {
        var l = lockForWrite()
        defer { l.unlock() }

        return try block()
    }

    public func lockForRead() -> Lock {
        AcquireSRWLockShared(&lock)

        return Lock(lock: self, isExclusive: false)
    }

    public func lockForWrite() -> Lock {
        AcquireSRWLockExclusive(&lock)

        return Lock(lock: self, isExclusive: true)
    }

    public struct Lock {
        var lock: ReadWriteLock
        var isExclusive: Bool
        var hasUnlocked: Bool = false

        public mutating func unlock() {
            guard !hasUnlocked else { return }
            hasUnlocked = true

            if isExclusive {
                ReleaseSRWLockExclusive(&lock.lock)
            } else {
                ReleaseSRWLockShared(&lock.lock)
            }
        }
    }
}

#else

#if os(Linux)
import Glibc
#elseif os(macOS)
import Darwin
#else
#error("Unsupported operating system")
#endif

public class ReadWriteLock {
    var lock: pthread_rwlock_t

    public init() {
        lock = pthread_rwlock_t()
        pthread_rwlock_init(&lock, nil)
    }

    deinit {
        pthread_rwlock_destroy(&lock)
    }

    public func lockingForRead<T>(_ block: () throws -> T) rethrows -> T {
        var l = lockForRead()
        defer { l.unlock() }

        return try block()
    }

    public func lockingForWrite<T>(_ block: () throws -> T) rethrows -> T {
        var l = lockForWrite()
        defer { l.unlock() }

        return try block()
    }

    public func lockForRead() -> Lock {
        pthread_rwlock_rdlock(&lock)

        return Lock(lock: self)
    }

    public func lockForWrite() -> Lock {
        pthread_rwlock_wrlock(&lock)

        return Lock(lock: self)
    }

    public struct Lock {
        var lock: ReadWriteLock
        var hasUnlocked: Bool = false

        public mutating func unlock() {
            guard !hasUnlocked else { return }
            hasUnlocked = true

            pthread_rwlock_unlock(&lock.lock)
        }
    }
}

#endif
