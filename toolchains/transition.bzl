
def _to_platform_impl(settings, attr):
    return {"//command_line_option:platforms": attr.platform}


to_platform = transition(
    implementation = _to_platform_impl,
    inputs = [],
    outputs = ["//command_line_option:platforms"],
)
