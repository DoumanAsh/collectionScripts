""" Trace module """

from datetime import datetime
from inspect import currentframe

class EventTracer():
    """ Event Tracer """
    def __init__(self, delimiter=" ", time=False):
        self.sep = delimiter
        self.time = None
        if time:
            self.time = datetime.now
        self.events = {"ERROR"   : True,
                       "WARNING" : True,
                       "INFO"    : False,
                       "DEBUG"   : False}

    def reset(self):
        """ Reset events to initial state. """
        self.__init__()

    def trace(self, event, *argv):
        """ Prints trace.

            Format: [timestamp] {event} - filename:line - func(): trace
        """
        event = event.upper()
        trace_to = ""

        try:
            if self.events[event] and argv:
                #timestamp
                timestamp = ""
                if self.time:
                    timestamp = " ".join((str(self.time()), timestamp))
                event = "".join((timestamp, "{", event, "}"))
                #filename + line
                frame = currentframe().f_back
                file_name = frame.f_code.co_filename
                file_line = ":".join((file_name, str(frame.f_lineno)))
                func_name = "".join((frame.f_code.co_name, "():"))

                trace_to = self.sep.join((event, "-", file_line, "-", func_name,
                                          " ".join(str(arg) for arg in argv)))

        except KeyError:
            #timestamp
            timestamp = ""
            if self.time:
                timestamp = " ".join((str(self.time()), timestamp))
            #filename + line
            frame = currentframe().f_back
            file_name = frame.f_code.co_filename
            file_line = ":".join((file_name, str(frame.f_lineno)))
            func_name = "".join((frame.f_code.co_name, "():"))

            trace_to = self.sep.join(("".join((timestamp, "{ERROR}")),
                                      "-", file_line, "-", func_name,
                                      "Unexpected event:", event, trace_to, "| Args:", str(argv)))

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
