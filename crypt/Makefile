.POSIX:

TARGETS = gbcrypt

# Override these either as assignment-arguments of "make" or via exported
# environment variables (and include "-e" in MAKEFLAGS for actually honoring
# the environment variables).
CPPFLAGS =
CFLAGS = -D NDEBUG -O
LDFLAGS = -s

# You should not need to change the rest.
.PHONY: all clean

AUG_CFLAGS = $(CPPFLAGS) $(CFLAGS) $(APP_CFLAGS)
APP_CFLAGS = -I .

.c:
	$(CC) $(AUG_CFLAGS) $(LDFLAGS) -o $@ $<

all: $(TARGETS)

clean:
	-rm $(TARGETS)
