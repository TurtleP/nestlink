import tables

type
    MessageState* = enum
        STATE_RECV,
        STATE_SEND

type
    Message* = object

        globals* : Table[string, string]
        history* : seq[string]
        mode*    : string
        state*   : MessageState

{.push base.}

method setGlobals*(self : var Message, data : seq[string]) =
    self.globals[data[1]] = data[2]

method getGlobals*(self : Message) : Table[string, string] =
    return self.globals

method addHistory*(self : Message, item : string) =
    # self.history.add(item)
    echo "!"

method getHistory*(self : Message) : seq[string] =
    return self.history

method setState*(self : var Message, state : MessageState) =
    self.state = state

method stateIs*(self : Message, state : MessageState) : bool =
    return self.state == state

{.pop base.}
