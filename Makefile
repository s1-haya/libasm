# Makefile -- build NASM (Intel syntax) 64-bit assembly, archive libasm.a, and test

NASM = nasm
CC   = clang
AR   = ar
RANLIB = ranlib

# Detect OS
UNAME_S := $(shell uname -s)

# Choose NASM format automatically
ifeq ($(UNAME_S),Darwin)
    NASM_FMT = macho64      # macOS (Intel target)
else ifeq ($(UNAME_S),Linux)
    NASM_FMT = elf64        # Linux (System V)
else
    $(error Unsupported OS: $(UNAME_S))
endif

ASM_SRC = add.s
ASM_OBJ = $(ASM_SRC:.s=.o)

LIB = libasm.a

TEST_SRC = main.c
TEST_BIN = test

.PHONY: all clean fclean re test

all: $(LIB)

%.o: %.s
	$(NASM) -f $(NASM_FMT) $< -o $@

$(LIB): $(ASM_OBJ)
	$(AR) rcs $(LIB) $(ASM_OBJ)
	-$(RANLIB) $(LIB) 2>/dev/null || true

test: $(LIB) $(TEST_SRC)
	$(CC) $(TEST_SRC) -L. -lasm -o $(TEST_BIN)
	./$(TEST_BIN)

clean:
	@rm -f $(ASM_OBJ)

fclean: clean
	@rm -f $(LIB) $(TEST_BIN)

re: fclean all
