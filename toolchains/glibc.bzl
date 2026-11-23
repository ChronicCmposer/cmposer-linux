# Highest glibc whose stubs may be linked into stage-0 tools.
# Must be <= the seed host's glibc (Debian sid currently: 2.43).
BOOTSTRAP_GLIBC = "2.43"

# The glibc we build and ship as a package.
TARGET_GLIBC = "2.44"
