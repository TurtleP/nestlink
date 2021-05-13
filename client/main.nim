import net
import strformat
import locks
import os
import tables
import sequtils

import cligen

let APP_NAME = "nëstlink"
let VERSION = "0.1.0"

var socket : Socket

var lock = Lock()
lock.initLock()

var finished = false

var globals : Table[string, string]
var history : seq[string]
var mode = "read"

proc handler() {.noconv.} =
    if mode == "read":
        mode = "command"

setControlCHook(handler)

proc threadFunc(socket: Socket) {.thread.} =
    while true:
        acquire(lock)

        if finished:
            break

        let data = socket.recvLine()

        if "global" in data:
            let split = data.split(";")
            globals[split[2]] = split[3]
        else:
            if mode == "read":
                echo(data)

        release(lock)

proc initialize() =
    ## Initialize nëstlink for debugging

    socket = newSocket(AF_INET, SOCK_STREAM, IPPROTO_TCP)

    try:
        socket.connect("localhost", Port(8000), 5)
    except TimeoutError:
        echo("Failed to connect to nëstlink host server.")
        return

    # Handle things here

    var thread : Thread[Socket]
    createThread(thread, threadFunc, socket)

    while true:
        if mode == "command":
            write(stdout, "Enter Command: ")
            let command = readLine(stdin)

            case command:
                of "quit":
                    break
                of "help":
                    echo "test"
                of "globals":
                    socket.send("globals\n")
                of "continue":
                    mode = "read"
                else:
                    socket.send(fmt("{command}\n"))

        sleep(1)

    finished = true
    joinThread(thread)
    lock.deinitLock()

    socket.close()

proc version() =
    ## Show version info and exit

    echo(fmt("{APP_NAME} {VERSION}"))

dispatchMulti([initialize], [version])
