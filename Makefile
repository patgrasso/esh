NAME	= esh
SRC	= esh.c string.c
OBJ	= $(SRC:.c=.o)
CC	= cc
RM	= rm -f
CFLAGS	= -Wall -Werror -Wpedantic -g
YFLAGS	= -Wall -Werror -t --verbose
LDLIBS	=

LEXSRC	= tokens.l
LEXOUT	= $(LEXSRC:.l=.yy.c)

YACCSRC	= parser.y
YACCOUT	= $(YACCSRC:.y=.tab.c)

PARSEOBJ= $(LEXOUT:.c=.o) $(YACCOUT:.c=.o)

.PHONY: clean fclean re tar parser debug

all: ${NAME}

%.yy.c: %.l
	lex -o $@ $^

%.tab.c: %.y
	yacc ${YFLAGS} -o $@ -d $^

%.yy.o: ${LEXOUT} ${YACCOUT}
	${CC} ${LDFLAGS} -Wno-error=unused-function -c ${LEXOUT}

%.tab.o: ${LEXOUT} ${YACCOUT}
	${CC} ${LDFLAGS} -Wno-error=unused-function -c ${YACCOUT}

parser: ${LEXOUT} ${YACCOUT}

# Compile + Link
${NAME}: ${PARSEOBJ} ${OBJ}
	${CC} ${LDFLAGS} ${PARSEOBJ} ${OBJ} -o ${NAME} ${LDLIBS}

debug: CFLAGS += -DDEBUG
debug: ${NAME}

# Tidy targets
clean:
	-${RM} *~
	-${RM} *.o
	-${RM} .*.swp
	-${RM} \#*
	-${RM} *.core
	-${RM} *.output
	-${RM} ${LEXOUT}
	-${RM} ${YACCOUT}
	-${RM} ${YACCSRC:.y=.tab.h}

fclean: clean
	-${RM} ${NAME}
	-${RM} ${NAME}.tar.gz

tar: fclean
	-tar -czvf ${NAME}.tar.gz *.c *.h *.y *.l Makefile

re: fclean all clean
