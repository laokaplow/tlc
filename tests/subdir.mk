
TEST_RUNNER = bin/test_runner
TEST_DIR = tests/

.PHONY: test
test: $(TARGET)
	$(TARGET) < tests/declaration.toyl | jsonpp

bin/test_runner: $(TEST_DIR)test_runner.cpp vendor/catch.hpp
	@mkdir -p $(@D)
	$(COMPILE) -o $@ $<
