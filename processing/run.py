import os
import struct
import sys
import threading
import time


def process_stream(win_len, infilename, outfilename, retries=5, delay=1):
    """process stream"""
    if infilename != "-":
        # Retry mechanism for opening the named pipe
        for _ in range(retries):
            if os.path.exists(infilename):
                infile = open(infilename, "rb")
                break
            time.sleep(delay)
        else:
            raise FileNotFoundError(f"Could not open named pipe: {infilename}")
    else:
        infile = sys.stdin.buffer

    if outfilename != "-":
        outfile = open(outfilename, "wb")
    else:
        outfile = sys.stdout.buffer

    buffer = []
    while True:
        data = infile.read(8)
        if not data:
            break
        value = struct.unpack("<d", data)[0]

        buffer.append(value)
        if len(buffer) > win_len:
            buffer.pop(0)

        if len(buffer) == win_len:
            avg = sum(buffer) / len(buffer)
            outfile.write(struct.pack("<d", avg))

    infile.close()
    if outfile is not sys.stdout.buffer:
        outfile.close()


if __name__ == "__main__":
    threads = []
    for arg in sys.argv[1:]:
        win_len, infilename, outfilename = arg.split(",")
        win_len = int(win_len)
        thread = threading.Thread(
            target=process_stream, args=(win_len, infilename, outfilename)
        )
        threads.append(thread)
        thread.start()

    for thread in threads:
        thread.join()
