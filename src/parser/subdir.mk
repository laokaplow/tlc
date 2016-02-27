# mark current location, (dir smartly appends slash)
SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
BASE_DIR := $(CUR_DIR) # bas edirectory, does not change with includes

# optionally, include more from here
include $(SELF_DIR)another.mk
