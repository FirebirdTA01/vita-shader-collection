TARGET_LIB = libvitashaders.a
SOURCES = src
INCLUDES = include
SHDIR		 = shaders
SHADERS   := $(foreach dir,$(SHDIR), $(wildcard $(dir)/*.cg))
#just a comment so there's something to push and I can test Travis CI

GXPS       = $(SHADERS:.cg=.gxp)
OBJS       = $(SHADERS:.cg=.o)

PREFIX  = arm-vita-eabi
CC      = $(PREFIX)-gcc
AR      = $(PREFIX)-ar
CFLAGS  = -Wall -I$(INCLUDES) -O3 -ftree-vectorize -mfloat-abi=hard -ffast-math -fsingle-precision-constant -ftree-vectorizer-verbose=2 -fopt-info-vec-optimized -funroll-loops
ASFLAGS = $(CFLAGS)

all: $(TARGET_LIB)


$(TARGET_LIB): $(OBJS)
	$(AR) -rc $@ $^

tools/raw2c: tools/raw2c.c
	cc $< -o $@


%_v.gxp: %_v.cg
	qemu-arm-static -L ./gcc-linaro-4.9-2015.02-3-x86_64_arm-linux-gnueabihf/arm-linux-gnueabihf/libc/ ./vita-shaders/shacc --vertex $^ $@


%_f.gxp: %_f.cg
	qemu-arm-static -L ./gcc-linaro-4.9-2015.02-3-x86_64_arm-linux-gnueabihf/arm-linux-gnueabihf/libc/ ./vita-shaders/shacc --fragment $^ $@


%_v.o: tools/raw2c %_v.gxp
	$< $(word 2,$^)
	mv *.h $(SHDIR)
	mv *.c $(SHDIR)
	$(CC) $(CFLAGS) -c $(patsubst %.gxp,%.c,$(word 2,$^)) -o $@
	
%_f.o: tools/raw2c %_f.gxp
	$< $(word 2,$^)
	mv *.h $(SHDIR)
	mv *.c $(SHDIR)
	$(CC) $(CFLAGS) -c $(patsubst %.gxp,%.c,$(word 2,$^)) -o $@

clean:
	@rm -rf $(TARGET_LIB) $(OBJS) $(GXPS) $(INCLUDES) $(SOURCES)
