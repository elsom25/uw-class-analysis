UW Class Analysis
=================

From a given term, using the api's from [api.uwaterloo.ca](api.uwaterloo.ca), creates a csv of all classes offered, the room, the professor, and the class size.

General usage
-------------

As displayed from `-h`:

    From a given term, using the api's from api.uwaterloo.ca, creates a csv of
    all classes offered, the room, the professor, and the class size.

    Usage: analyse_classes [options]

    Required options:
        -t, --term 1141                  Required. The term to analyze class data for.
        -a, --api API_KEY                Optional. Specify your API key.

    Common options:
        -h, --help                       Show this message
            --version                    Show version

Structure
---------

The key things to know if you want to get hacking is:

- `analyse_classes` is the client code, and acts as the command line tool.

- `class_data.rb` is the implementation, and where the magic happens.

Outputs
-------

A single file `__class_data_(TERM_ID).csv` in the directory the script was run from of crunched results that may be consumed as needed. (yay excel!)
