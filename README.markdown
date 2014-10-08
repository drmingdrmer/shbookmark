`shbookmark` is path bookmark engine on shell.
Go to directory with minimal typing, in fuzzy searching mode.

# Install

Add the following line to ~/.bashrc:

    source <path_to_shbookmark>/bin/shbookmark.sh make_alias


# Usage

## "ga":

Add `pwd` to bookmark.

## "ga path":

Add `path` to bookmark.

## "gdel":

Delete `pwd` from bookmark.

Or Edit directly ~/.shbookmark to delete/orgnize bookmark entries.

## "gclean":

Delete all inexistent bookmark entries.

## "g key1 [key2 [key3..]]":

Go to the directory that matches keywords key1, key2..

If only one directory matched, it goes to the directory at
once.
Or it lists all direcotries matched for narrawing search.

For example, "g" without argument shows:

       1 --- ~/VCS/git/SAE_SDK_Linux_Mac/
       2 --- ~/VCS/gitsvn/bbtt.com
       ...
       7 --- ~/bash.xp/plugin/shbookmark
    (Press ENTER to select by number)
    Search For :


"g VCS" shows:

       1 --- ~/VCS/git/SAE_SDK_Linux_Mac/
       2 --- ~/VCS/gitsvn/bbtt.com
    (Press ENTER to select by number)
    Search For :

Now input "svn" it goes to "~/VCS/gitsvn/bbtt.com".

The above working flow is equivalent to "g VCS gitsvn".

## "g key1 -key2":

    look for directory that contains "key1" but not contains "key2".


# Customization

## Change Command Prefix

By default shbookmark alias prefix is `g`. User could define his own prefix.

To use "bk" as prefix, load shbookmark with argument `bk`:

    source <path_to_shbookmark>/bin/shbookmark.sh make_alias bk

Thus commands will be: "bkadd", "bkdel", "bkclean", "bk"

## Environment Variable Options

`export SHBOOKMARK_TREE=1`

    Default:""
    "1" turns on bookmark displaying in tree view.

`export SHBOOKMARK_COLOR=1`

    Default:"1"
    "1" turns on highlighting of matched keywords.

`export SHBOOKMARK_CASE_SENSITIVE=1`

    Default:"0"
    "1" turns on case sensitive matching.

