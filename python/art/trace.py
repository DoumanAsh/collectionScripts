""" Trace module """

from datetime import datetime
from inspect import currentframe

class EventTracer():
    """ Event Tracer """
    def __init__(self, delimiter=" ", timestamp=False):
        self.sep = delimiter
        if timestamp:
            self.time = datetime.now
        else:
            self.time = None
        self.events = {"ERROR"   : True,
                       "WARNING" : True,
                       "INFO"    : False,
                       "DEBUG"   : False}

    def reset(self):
        """ Reset events to initial state. """
        self.__init__()

    def trace(self, event, *argv):
        """ Prints trace. """
        event = event.upper()
        trace_to = ""

        #function name and line of caller
        frame = currentframe().f_back
        func_line = ":".join(("".join((frame.f_code.co_name, "()")), str(frame.f_lineno)))

        try:
            if self.events[event] and argv:
                #header: date and time + {EVENT}
                trace_to = "".join(("{", event, "}"))
                if self.time:
                    trace_to = self.sep.join((str(self.time()), trace_to))
                #compose trace
                trace_to = self.sep.join((trace_to, "-", func_line, "-",
                                          " ".join(str(arg) for arg in argv)))

        except KeyError:
            trace_to = self.sep.join(("{ERROR}", "-", func_line, "-",
                                      "Unexpected event:", event, trace_to, "| Args:", str(argv)))
            if self.time:
                self.sep.join((str(self.time()), trace_to))

        if trace_to:
            print(trace_to)

    def set_event(self, name, enabled=True):
        """ Add event to table if there is no such event.
            Otherwise updates event's state.
        """
        name = name.upper()
        self.events[name] = enabled

    def set_time(self, enable=True):
        """ Enable or disable timestamp. """
        if enable:
            self.time = datetime.now
        else:
            self.time = None
