#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <sys/mman.h>
#include <sys/select.h>


int main(int argc, char *argv[], char *envp[]) {
	size_t nkb = 4096;
	void *ptr;
	int retval;
	int pipefd[2];
	fd_set fds;
	int nsec = 0;
	struct timeval tv;

	if (argc > 1) {
		nkb=atoll(argv[1]);
		if (!nkb) {
			fprintf(stderr, "Usage: pin kb\n");
			exit(1);
		}
	}
	
	if (argc > 2) {
		nsec = atoi(argv[2]);
	}

	if (nsec)
		fprintf(stdout, "Allocated %zdkB and waiting %ds\n", nkb, nsec);
	else
		fprintf(stdout, "Allocated %zdkB and waiting indefinitely\n", nkb);

	ptr = malloc(nkb * 1024);
	if (!ptr) {
		fprintf(stderr, "Failed to allocate %zdkB\n", nkb);
		exit(1);
	}

	retval = mlock(ptr, nkb * 1024);
	if (retval < 0) {
		perror("mlock");
		exit(1);
	}

	retval = pipe(pipefd);
	if (retval < 0) {
		perror("pipe");
		exit(1);
	}

	/* block forever */
	FD_ZERO(&fds);
	FD_SET(pipefd[0], &fds);
	if (nsec) {
		tv.tv_sec = nsec;
		tv.tv_usec = 0;
		retval = select(1, &fds, NULL, NULL, &tv);
	} else {
		retval = select(1, &fds, NULL, NULL, NULL);
	}
		
	if (retval < 0) {
		if (errno == EINTR) {
			fprintf(stdout, "Interrupted\n");
		} else {
			perror("select");
			exit(1);
		}
	} else if (retval) {
		fprintf(stderr, "wtf\n");
	} else {
		fprintf(stdout, "Timeout expired\n");
	}
	exit(0);
}
