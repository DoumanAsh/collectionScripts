init python:
    config.console = True
    import re

    def find_symbols_iter(dir, pattern):
        if pattern:
            regex = re.compile(pattern)

            for symbol in dir:
                if regex.search(symbol):
                    yield symbol

    def find_symbols(dir, pattern):
        return "; ".join(find_symbols_iter(dir, pattern))
