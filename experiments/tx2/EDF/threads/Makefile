SRCS=deadline.c
TGT=test_deadline

all: ${TGT}
${TGT}: ${SRCS}
	gcc $< -o $@ -lpthread

clean:
	rm -f ${TGT}
