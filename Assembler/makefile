ODIR = Debug
OUT = $(ODIR)/assembler.a
CC = gcc
SDIR = .
INC = -Iinc
LINK_TARGET = $(ODIR)/assembler.exe
MKDIR_P = mkdir -p

_OBJS = main.o assembler.o help.o list.o instructions.o serial.o gccSerial.o
OBJS = $(patsubst %,$(ODIR)/%,$(_OBJS))

all: directories $(LINK_TARGET)

$(LINK_TARGET): $(OBJS)
	$(CC) -g -o $@ $^

$(ODIR)/%.o: $(SDIR)/%.c
	$(CC) -c $(INC) -o $@ $< $(CFLAGS)

$(OUT): $(OBJS)
	ar rvs $(OUT) $^

.PHONY: clean

clean:
	rm -f $(ODIR)/*.o $(OUT) $(LINK_TARGET)

.PHONY: directories

directories: $(ODIR)

$(ODIR):
	$(MKDIR_P) $(ODIR)
