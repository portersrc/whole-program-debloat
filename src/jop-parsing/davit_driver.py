import time
import subprocess
import re
import sys
from threading  import Thread
from Queue import Queue, Empty


ROCKET_COMMANDS = "Z\nP\n"


def usage_and_exit():
    print('')
    print('Usage:')
    print('  {} <executable_to_run_jop_rocket_on>'.format(sys.argv[0]))
    print('')
    sys.exit(1)


def parse_args():
    if len(sys.argv) != 2:
        usage_and_exit()
    return sys.argv[1]


def launch_proc(executable):
    try:
        proc = subprocess.Popen(['python', 'rocket.py', executable], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    except:
        print("Popen failed. Perhaps check file name. Exiting....")
        sys.exit(2)
    return proc


def enqueue_output(out, queue):
    for line in iter(out.readline, b''):
        queue.put(line)
    out.close()


def drive_jop_rocket(executable):
    print('Driving rocket.py for executable: {}'.format(executable))

    q = Queue()

    proc = launch_proc(executable)
    proc.stdin.write(bytes(ROCKET_COMMANDS))

    # XXX Not properly handling thread shutdown. Don't care for now.
    t = Thread(target=enqueue_output, args=(proc.stdout, q))
    t.daemon = True # thread dies with the program
    t.start()


    last_line = ''
    while True:
        # read line without blocking
        try:
            #line = q.get_nowait()
            line = q.get(timeout=5)
        except Empty:
            break
        else:
            #print('got line: {}'.format(line))
            last_line = line


    # The "prompt" for the next command should be three dots. If that's not
    # the last thing we saw, something may have still been running when we broke
    # out of the loop, so the timeout may need to be increased
    if last_line.strip() != '...':
        print('Unexpected last line: {}'.format(last_line))
        sys.exit(3)

    proc.terminate()




executable = parse_args()

if executable == 'RUN_ALL_NGINX':
    nginx_pg_files_path = 'C:/Users/rudy/h/wo/decker/whole-program-debloat/src/gadget-chains/output/nginx'
    for x in xrange(142):
        executable = '{}/nginx_pg_{}.bin'.format(nginx_pg_files_path, x)
        drive_jop_rocket(executable)
else:
    drive_jop_rocket(executable)

