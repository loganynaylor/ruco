Simple, extendable, test-driven commandline editor written in ruby.

Features:

 - **Intuitive interface**
 - selecting via Shift+left/right/up/down and Ctrl+a(all)
 - Tab -> indent / Shift+Tab -> unindent
 - keeps indentation (+ paste-detection e.g. via Cmd+v)
 - change (*) + writable (!) indicators
 - find / go to line / delete line / search & replace
 - configuration via `~/.ruco.rb`
 - cut, copy and paste -> Ctrl+x/c/v
 - undo / redo
 - stays at last position when reopening a file
 - (optional) remove trailing whitespace on save

Install
=======
    sudo gem install ruco

Usage
=====
    ruco file.rb

Customize
=========

    # ~/.ruco.rb
    Ruco.configure do
      # set options
      options.window_line_scroll_offset = 5 # default 1
      options.history_entries = 10          # default 100
      options.editor_remove_trailing_whitespace_on_save = true # default false
      ...

      # bind a key
      # - you can use Integers and Symbols
      # - use "ruco --debug-keys foo" to see which keys are possible
      # - have a look at lib/ruco/keyboard.rb
      bind(:"Ctrl+e") do
        ask('foo') do |response|
          if response == 'bar'
            editor.insert('baz')
          else
            editor.move(:to, 0,0)
            editor.delete(99999)
            editor.insert('FAIL!')
          end
        end
      end

      # bind an existing action
      puts @actions.keys

      bind :"Ctrl+x", :quit
      bind :"Ctrl+o", :save
      bind :"Ctrl+k", :delete_line

      # create reusable actions
      action(:first){ editor.move(:to_column, 0) }
      bind(:"Ctrl+a", :first)
      bind(:home, :first)
    end

TIPS
====
 - [Tabs] Ruco does not like tabs. Existing tabs are displayed as ' ' and pressing tab inserts 2*' '
 - [RVM] `alias r="rvm ree exec ruco"` and you only have to install ruco once
 - [Ruby1.9] Unicode support -> install libncursesw5-dev before installing ruby (does not work for 1.8)
 - [ssh vs clipboard] access your desktops clipboard by installing `xauth` on the server and then using `ssh -X`
 - [Alt key] if Alt does not work try your Meta/Win/Cmd key

TODO
=====
 - align soft-tabs
 - handle \\r and \\r\\n nicely <-> breaks curses output
 - highlight tabs (e.g. strange character or reverse/underline/color)
 - big warning when editing a not-writable file
 - find next (Alt+n)
 - add selection colors to forms in command_bar
 - smart staying at column when changing line
 - syntax highlighting
 - raise when binding to a unsupported key
 - search history via up/down arrow
 - search options regex + case-sensitive
 - add auto-confirm to 'replace?' dialog -> type s == skip, no enter needed
 - 1.8: unicode support <-> already finished but unusable due to Curses (see encoding branch)
 - support Alt+Fx keys
 - (later) extract keyboard and html-style components into separate project

Author
======
[Michael Grosser](http://grosser.it)<br/>
grosser.michael@gmail.com<br/>
Hereby placed under public domain, do what you want, just do not hold me accountable...
