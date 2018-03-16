# Using the myoutline gem to help build an index from an outline


## Usage

    require 'myoutline'


    s =<<EOF
    apple
    antelope
    asterisk
      configuring extensions
        messing
    button
      whatever
    confetti
    configuring extensions
    EOF

    mo = MyOutline.new(s)
    puts mo.to_s

Output:

<pre>
&lt;?ph schema="entries/entry[title]"?&gt;

# a

apple
antelope
asterisk
  configuring extensions
    messing

# b

button
  whatever

# c

confetti
configuring extensions

# m

messing

# w

whatever
</pre>

## Resources

* myoutline https://rubygems.org/gems/myoutline

myoutline gem index outline thoughts pxindex
