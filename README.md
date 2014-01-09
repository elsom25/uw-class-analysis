Feds Election Analysis
======================

Consumes multiple `csv` files to build a voters list, and multiple `txt` files of results data.

General usage
-------------

As displayed from `-h`:

    Parses election data given student voter lists and election meta-data to better understand oter behaviour.

    Usage: analyse_election [options]

    Required options:
        -v, --voters A.csv,B.csv         Required. The files that collectively create the voters list.
        -r, --results X.txt,Y.txt        Required. The files that collectively create the results.

    Common options:
        -h, --help                       Show this message
            --version                    Show version

Structure
---------

The key things to know if you want to get hacking is:

- `analyse_election` is the client code, and acts as the command line tool.

- `election_data.rb` is the implementation, and where the magic happens.

Outputs
-------

A single file `__election_data.csv` in the directory the script was run from of crunched results that may be consumed as needed. (yay excel!)

The plan is to eventually also output an analysed dataset.
