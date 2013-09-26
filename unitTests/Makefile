CC = clang
API = "../ClearBladeAPI/"
AFN = "/Users/charlie/Dev/AFNetworking/"
CFLAGS = -fobjc-arc -I$(API) -I$(AFN) -framework Cocoa -framework Security
IMPS = $(API)*.m $(AFN)AFNetworking/*.m
SOURCES = test.m

all: test

test:
	$(CC) $(CFLAGS) $(IMPS) $(SOURCES) -o test

clean: 
	rm -rf test
