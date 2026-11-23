

rule(
    attrs = {
        "platform": attr.label(
            default = "//toolchains/platforms:linux_aarch64_cmposer",
        ),
        # ...
    },
    cfg = to_platform,
)
