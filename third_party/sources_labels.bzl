def source(name):
    """Label of the pinned source tree for a lock-file entry."""
    return "@source_{}//:src".format(name)
