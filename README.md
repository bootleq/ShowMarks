ShowMarks.vim
=============

Modified version of Anthony Kruize's [ShowMarks][original version] plugin:  
http://www.vim.org/scripts/script.php?script_id=152


Usage
=====

Default key mappings:

  - `<Leader>mt`  - Toggle whether marks are displayed or not.
  - `<Leader>mo`  - Turn ShowMarks on, and displays marks.
  - `<Leader>mh`  - Clear mark on current line.
  - `<Leader>ma`  - Clear all marks.
  - `<Leader>mm`  - Places next available mark.

Also provide commands for these functions.


Configuration
=============

  - `let g:showmarks_auto_toggle = 0`  
    Don't open ShowMarks with CursorHold autocommand.
  - `let g:showmarks_no_mappings = 1`  
    Disable default key mappings.
  - `let g:showmarks_include = "abcdBA"`  
    Only handle 'abcdBA' marks.  
    When using `:ShowMarksPlaceMark`, marks earlier in this list take
    precedence over latters.
  - `let g:showmarks_ignore_type = "h"`  
    Don't use ShowMarks with help files.
  - `let g:showmarks_textlower = "\t>"`  
    Display lowercase marks with a "&gt;" suffix.
  - `let g:showmarks_hlline_lower = 1`  
    Highlight entire line where a lowercase mark is on.

See plugin doc for all options.


Changes Since Original Version
==============================

Original version (2.2) was written in 2004 and suitable for Vim 6.0.  
This version should be more compatible with Vim 7, and will keep maintained.


Requirements
============

- Vim 7.0 or later.
- Compiled with the +signs feature.

[original version]: http://www.vim.org/scripts/script.php?script_id=152
