import Darwin

/// Apps started from the Finder may keep only 256 files open, sockets
/// included, which a handful of idle clients and a few downloads use up.
enum FileDescriptorLimit {

    static func raise(to wanted: rlim_t) {
        var limit = rlimit()
        guard getrlimit(RLIMIT_NOFILE, &limit) == 0, limit.rlim_cur < wanted
        else {
            return
        }
        limit.rlim_cur = min(wanted, limit.rlim_max)
        // Falling short only means the old limit stays.
        _ = setrlimit(RLIMIT_NOFILE, &limit)
    }
}
