import net
import strformat
import locks
import os
import strutils

import cligen

import message

let APP_NAME = "nëstlink"
let VERSION = "0.1.0"

var soc : Socket
var msg : Message

var finished : bool

var lock = Lock()

proc threadFunc(arg: tuple[socket : Socket, message : var Message]) {.thread.} =
    while true:
        acquire(lock)

        if finished:
            break

        let data = arg.socket.recvLine()

        if not data.isEmptyOrWhitespace():
            if "global" in data:
                let split = data.split(";")
                arg.message.setGlobals(split)

        if arg.message.stateIs(MessageState.STATE_RECV):
            echo(data)

        sleep(1)

        release(lock)

proc cleanup() =
    acquire(lock)
    finished = true
    release(lock)

    deinitLock(lock)

proc start() =
    ## Initialize nëstlink for debugging

    soc = newSocket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
    msg = Message(state: MessageState.STATE_RECV)

    try:
        soc.connect("localhost", Port(8000), 5)
    except TimeoutError:
        echo("Failed to connect to nëstlink host server.")
        return

    # Handle things here
    finished = false
    var thread : Thread[tuple[socket : Socket, message : Message]]

    initLock(lock)

    createThread(thread, threadFunc, (soc, msg))

    while true:
        if msg.stateIs(MessageState.STATE_SEND):
            write(stdout, "Enter Command: ")
            let command = readLine(stdin)

            case command:
                of "quit":
                    break
                of "help":
                    echo "test"
                of "globals":
                    soc.send("globals\n")
                of "continue":
                    # mode = "read"
                    break
                else:
                    soc.send(fmt("{command}\n"))

    cleanup()
    joinThread(thread)

    soc.close()

proc version() =
    ## Show version info and exit

    echo(fmt("{APP_NAME} {VERSION}"))

when isMainModule:
    dispatchMulti([start], [version])
