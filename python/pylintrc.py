#
# dotfiles : https://github.com/saigkill/dotfiles
#
# Setup pylint
#
# Authors:
#   Ben O'Hara <bohara@gmail.com>
#

[MESSAGES CONTROL]
# Brain-dead errors regarding standard language features
#   W0142 = *args and **kwargs support
#   W0403 = Relative imports

# Pointless whinging
#   R0201 = Method could be a function
#   W0212 = Accessing protected attribute of client class
#   W0613 = Unused argument
#   W0232 = Class has no __init__ method
#   R0903 = Too few public methods
#   C0301 = Line too long
#   R0913 = Too many arguments
#   C0103 = Invalid name
#   R0914 = Too many local variables

# PyLint's module importation is unreliable
#   F0401 = Unable to import module
#   W0402 = Uses of a deprecated module

# Already an error when wildcard imports are used
#   W0614 = Unused import from wildcard

# Sometimes disabled depending on how bad a module is
#   C0111 = Missing docstring

# Disable the message(s) with the given id(s).
# NOTE: the Stack Overflow thread uses disable-msg, but as of pylint 0.23.0, disable= seems to work.
disable=W0142,W0403,R0201,W0212,W0613,W0232,R0903,W0614,C0111,C0301,R0913,C0103,F0401,W0402,R0914


[REPORTS]
# Set the output format. Available formats are text, parseable, colorized, msvs
# (visual studio) and html
output-format=text

# Include message's id in output
include-ids=no

# Put messages in a separate file for each module / package specified on the
# command line instead of printing them on stdout. Reports (if any) will be
# written in a file name "pylint_global.[txt|html]".
files-output=no

# Tells whether to display a full report or only the messages
reports=no

