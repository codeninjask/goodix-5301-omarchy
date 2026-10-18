sigfm_sources = ['sigfm.cpp']

# OpenCV 5 renamed the pkg-config module, accept both
opencv = dependency('opencv5', 'opencv4', required: true)
# doctest is only needed for the SIGFM unit tests
doctest = dependency('doctest', required: false)

libsigfm = static_library('sigfm',
        sigfm_sources,
        dependencies: [opencv],
)

# The optional standalone test uses omitted recorded fingerprint fixtures.
if doctest.found() and fs.exists(meson.current_source_dir() / 'tests-embedded.hpp')
    sigfm_tests = executable('sigfm-tests', ['./tests.cpp'], dependencies: [doctest, opencv], link_with: [libsigfm])
endif
