OUT = Debug/assembler.a
CC = gcc
ODIR = Debug
SDIR = .
INC = -Iinc
LINK_TARGET = Debug/assembler.exe

_OBJS = main.o assembler.o help.o list.o
OBJS = $(patsubst %,$(ODIR)/%,$(_OBJS))

all: $(LINK_TARGET)

$(LINK_TARGET): $(OBJS)
	$(CC) -g -o $@ $^

$(ODIR)/%.o: $(SDIR)/%.c
	$(CC) -c $(INC) -o $@ $< $(CFLAGS)

$(OUT): $(OBJS)
	ar rvs $(OUT) $^

.PHONY: clean

clean:
	rm -f $(ODIR)/* $(OUT) $(LINK_TARGET)
