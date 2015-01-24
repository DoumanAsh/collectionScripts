""" Trace module """

from datetime import datetime

class EventTracer():
    """ Event Tracer """
    def __init__(self, delimiter=" "):
        self.sep = delimiter
        self.time = datetime.now
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

        try:
            if self.events[event] and argv:
                #header: date and time + {EVENT}
                trace_to = "".join(("{", event, "}"))
                if self.time:
                    trace_to = self.sep.join((str(self.time()), trace_to))
                #add list of arguments to trace
                trace_to = self.sep.join((trace_to, " ".join(str(arg) for arg in argv)))

        except KeyError:
            trace_to = self.sep.join((str(self.time()), "{ERROR}", "Unexpected event:", event))
            trace_to = self.sep.join((trace_to, "| Args:", str(argv)))

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
