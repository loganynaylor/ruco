Simple, extendable, test-driven commandline editor written in ruby.

Features:

 - **Intuitive interface**
 - selecting via Shift+left/right/up/down and Ctrl+a(all)
 - Tab -> indent / Shift+Tab -> unindent (tab == 2 space)
 - keeps indentation (+ paste-detection e.g. via Cmd+v)
 - change (*) + writable (!) indicators
 - find / go to line / delete line / search & replace
 - configuration via `~/.ruco.rb`
 - cut, copy and paste -> Ctrl+x/c/v
 - undo / redo

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
      # bind a key, you can use Integers and Symbols
      # use "ruco --debug-keys foo" to see which keys are possible
      # or have a look at lib/ruco/keyboard.rb
      bind(:"Ctrl+e") do
        ask('delete ?') do |response|
          if response or not response
            editor.move(:to, 0, 0)
            editor.delete(9999)
          end
        end
      end

      # bind an existing action
      puts @actions.keys

      bind(:"Ctrl+x", :quit)
      bind(:"Ctrl+o", :save)
      bind(:"Ctrl+k", :delete_line)

      # define a new action and bind it to multiple keys
      action(:first){ editor.move(:to_column, 0) }
      bind(:"Ctrl+a", :first)
      bind(:home, :first)
    end

TIPS
====
 - [Ruby1.9] Unicode support -> install libncursesw5-dev before installing ruby (does not work for 1.8)
 - [ssh vs clipboard] access your desktops clipboard by installing `xauth` on the server and then using `ssh -X`
 - [Alt key] if Alt does not work try your Meta/Win/Cmd key

TODO
=====
 - make modified smarter <-> no manual addition of every action
 - make history more efficient (e.g. no need to check when only moving / store only diffs)
 - limit possible file size to e.g. 1MB (would hang/be too slow with big files)
 - find next (Alt+n)
 - add selection colors to forms in command_bar
 - session storage (stay at same line/column when reopening)
 - smart staying at column when changing line
 - warnings / messages
 - syntax highlighting
 - raise when binding to a unsupported key
 - search history via up/down arrow
 - search options regex + case-sensitive
 - add auto-confirm to 'replace?' dialog -> type s == skip, no enter needed
 - 1.8: unicode support <-> already finished but unusable due to Curses (see encoding branch)
 - support Alt+Fx keys
 - (later) extract keyboard and html-style components into seperate project

Author
======
[Michael Grosser](http://grosser.it)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...
