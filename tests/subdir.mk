
bin/test_runner: test_runner.cpp vendor/catch.hpp | bin
	$(COMPILE) $< -o $@

# todo, handwritten tests, dynamic tests
# better dependency management

# specific test runners that ensure freshness of code / tests

# cached test results?

CLEAN_LIST += ...?
