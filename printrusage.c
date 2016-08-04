#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/resource.h>

struct rusage r;
int retval, wstatus;
pid_t child;

int main (int argc, char *argv[], char *envp[]) {

	child = fork();

	if (child == 0) {
		/* child */
		retval = execve(argv[1], &argv[1], envp);
		perror("execve");
		exit(1);
	}
	if (child == -1) {
		perror("fork");
		exit(1);
	}
	retval = waitpid(child, &wstatus, 0);
	if (retval < 0) {
		perror("wait");
		exit(1);
	} else if (retval != child) {
		fprintf(stderr, "wtf, waitpid returned pid=%d instead of child %d\n", retval, child);
		exit(1);
	}

	retval = getrusage(RUSAGE_CHILDREN, &r);
	if (retval != 0) {
		perror("getrusage");
		exit(1);
	}

	printf("utime=%ld.%06ld stime=%ld.%06ld "
		   "maxrss=%ld ixrss=%ld idrss=%ld isrss=%ld minflt=%ld majflt=%ld "
		   "nswap=%ld inblock=%ld oublock=%ld msgsnd=%ld msgrcv=%ld "
		   "nsignals=%ld nvcsw=%ld nivcsw=%ld\n",
		   r.ru_utime.tv_sec, r.ru_utime.tv_usec,
		   r.ru_stime.tv_sec, r.ru_stime.tv_usec,
		   r.ru_maxrss, r.ru_ixrss, r.ru_idrss, r.ru_isrss, r.ru_minflt, r.ru_majflt, 
		   r.ru_nswap, r.ru_inblock, r.ru_oublock, r.ru_msgsnd, r.ru_msgrcv, 
		   r.ru_nsignals, r.ru_nvcsw, r.ru_nivcsw);
	exit(0);
}
