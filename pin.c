#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <sys/mman.h>
#include <sys/select.h>


int main(int argc, char *argv[], char *envp[]) {
	size_t nbytes = 4096;
	void *ptr;
	int retval;
	int pipefd[2];
	fd_set fds;
	int nsec = 0;
	struct timeval tv;

	if (argc > 1) {
		nbytes=atoll(argv[1]);
		if (!nbytes) {
			fprintf(stderr, "Usage: pin bytes\n");
			exit(1);
		}
	}
	
	if (argc > 2) {
		nsec = atoi(argv[2]);
	}

	if (nsec)
		fprintf(stdout, "Allocated %zd bytes and waiting %ds\n", nbytes, nsec);
	else
		fprintf(stdout, "Allocated %zd bytes and waiting indefinitely\n", nbytes);

	ptr = malloc(nbytes);
	if (!ptr) {
		fprintf(stderr, "Failed to allocate %zd bytes\n", nbytes);
		exit(1);
	}

	retval = mlock(ptr, nbytes);
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
