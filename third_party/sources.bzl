:"""Lock-file driven upstream source repositories."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_REQUIRED_FIELDS = ["name", "version", "urls", "sha256"]

def _require(entry, field):
    if field not in entry or entry[field] == "":
        fail(
            "sources.lock.json: entry %r is missing %r" %
            (entry.get("name", "<unnamed>"), field),
        )

def _validate_entries(entries):
    names = {}
    for entry in entries:
        for field in _REQUIRED_FIELDS:
            _require(entry, field)

        name = entry["name"]
        if name in names:
            fail("sources.lock.json: duplicate source %r" % name)
        names[name] = True

        if len(entry["sha256"]) != 64:
            fail("sources.lock.json: %r has a malformed sha256" % name)

def _patches_for(entry):
    name = entry["name"]
    return [
        Label("//third_party/patches:%s/%s" % (name, patch))
        for patch in entry.get("patches", [])
    ]

def _sources_impl(mctx):
    root = mctx.modules[0]
    if not root.is_root:
        fail("the `sources` extension must be used by the root module")

    if len(root.tags.index) != 1:
        fail("declare exactly one sources.index(file = ...) tag")

    lock = json.decode(mctx.read(mctx.path(root.tags.index[0].file)))
    if "sources" not in lock:
        fail("sources.lock.json: top-level `sources` array is required")

    entries = lock["sources"]
    _validate_entries(entries)

    for entry in entries:
        name = entry["name"]
        patches = _patches_for(entry)
        http_archive(
            name = "source_" + name,
            urls = entry["urls"],
            sha256 = entry["sha256"],
            strip_prefix = entry.get("strip_prefix", ""),
            build_file = Label("//third_party:source.BUILD.bazel"), # What is this ?
            patch_args = ["-p" + str(entry.get("patch_strip", 1))] if patches else [], # What is this  ?
            patches = patches,
        )

    return mctx.extension_metadata(
        reproducible = True,
        root_module_direct_deps = ["source_" + entry["name"] for entry in entries],
        root_module_direct_dev_deps = [],
    )


_sources_index_tag = tag_class(
    attrs = {
        "file": attr.label(
            allow_single_file = [".json"],
            mandatory = True,
        ),
    },
)

sources = module_extension(
    implementation = _sources_impl,
    tag_classes = {"index": _sources_index_tag}, # What is this?
)






