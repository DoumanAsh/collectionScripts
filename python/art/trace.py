""" Trace module """

from datetime import datetime
from inspect import currentframe

class EventTracer():
    """ Event Tracer

        Provides shortcuts for trace events:
        self.[event]()
    """
    def __init__(self, delimiter=" ", time=False, file_name=None):
        self.sep = delimiter
        self.time = None
        if time:
            self.time = datetime.now
        self.frame = None
        self.events = dict()
        for name, value in (("ERROR", True), ("WARNING", True), ("INFO", False), ("DEBUG", False)):
            self.set_event(name, value)
        self.log_fd = None
        if file_name:
            try:
                self.log_fd = open(file_name, 'a')
                self.__init_log_fd__()
            except IOError as errno:
                self.trace("ERROR", "Not possible to use log file:", file_name, "| Error:", errno)

    def reset(self):
        """ Reset events to initial state. """
        self.__init__()

    def __init_log_fd__(self):
        """ Function to write log header """
        self.log_fd.write("================= Event log =================\n")
        self.log_fd.write("=== Start time:{} ===\n".format(datetime.now()))
        self.log_fd.write("=============================================\n")

    def close(self):
        """ Closes logging class
            Should be called before application closure
        """
        if self.log_fd:
            self.log_fd.write("=============================================\n")
            self.log_fd.write("=== End time: {} ===\n".format(datetime.now()))
            self.log_fd.close()
            self.log_fd = None

    def trace(self, event, *argv):
        """ Prints trace.

            Format: [timestamp] {event} - filename:line - func(): trace
        """
        event = event.upper()
        trace_to = ""

        try:
            if self.events[event]:
                #timestamp
                timestamp = ""
                if self.time:
                    timestamp = " ".join((str(self.time()), timestamp))
                event = "".join((timestamp, "{", event, "}"))
                #filename + line
                if not self.frame:
                    self.frame = currentframe()
                frame = self.frame.f_back
                file_name = frame.f_code.co_filename
                file_line = ":".join((file_name, str(frame.f_lineno)))
                func_name = "".join((frame.f_code.co_name, "()"))

                trace_to = self.sep.join((event, "-", " ".join(str(arg) for arg in argv),
                                          "[", func_name, "-", file_line, "]"))

        except KeyError:
            #timestamp
            timestamp = ""
            if self.time:
                timestamp = " ".join((str(self.time()), timestamp))
            #filename + line
            if not self.frame:
                self.frame = currentframe()
            frame = self.frame.f_back
            file_name = frame.f_code.co_filename
            file_line = ":".join((file_name, str(frame.f_lineno)))
            func_name = "".join((frame.f_code.co_name, "()"))

            trace_to = self.sep.join(("".join((timestamp, "{ERROR}")), "-",
                                      "Unexpected event:", event, trace_to, "| Args:", str(argv),
                                      "[", func_name, "-", file_line, "]"))

        if trace_to:
            print(trace_to)
            if self.log_fd:
                self.log_fd.write("".join((trace_to, '\n')))

    def set_event(self, name, enabled=True):
        """ Add event to table if there is no such event.
            Otherwise updates event's state.
        """
        name = name.upper()
        self.events[name] = enabled
        #add shortcut for new event
        if not hasattr(self, name):
            def __trace(self, *argv):
                """ simple implementation of shortcuts """
                self.frame = currentframe()
                self.trace(name, *argv)
                self.frame = None
            setattr(self.__class__, name, __trace)

    def set_time(self, enable=True):
        """ Enable or disable timestamp. """
        if enable:
            self.time = datetime.now
        else:
            self.time = None

    def set_log_file(self, file_name):
        """ Initiate logging to file.

            @param file_name Valid and absolute name of file.
        """
        if self.log_fd:
            self.close()
        try:
            self.log_fd = open(file_name, 'a')
            self.__init_log_fd__()
        except IOError as errno:
            self.trace("ERROR", "Not possible to use log file:", file_name, "| Error:", errno)
