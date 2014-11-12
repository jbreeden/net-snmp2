net-snmp2
=========

[![Gem Version](https://badge.fury.io/rb/net-snmp2.svg)](http://badge.fury.io/rb/net-snmp2)

Just getting started? Checkout the [wiki](https://github.com/jbreeden/net-snmp2/wiki)

An object oriented Ruby wrapper around the C [netsnmp](http://www.net-snmp.org) libraries.
It provides classes for manager sessions, agents, pdus, varbinds, MIB inspection, and more.

The gem also includes some useful executables including:

- **net-snmp2**
  + An interactive REPL for inspecting the MIB, and acting as an SNMP manager.
  + Supports managing multiple agents at once.
  + Implemented on top of [Pry](http://pryrepl.org/), so it inherits all of Pry's goodness.
- **mib2rb**
  + A [mib2c](http://www.net-snmp.org/wiki/index.php/Mib2c) like tool that uses ERB files to format and display the system MIB.
  + mib2rb has a default template that prints the MIB details in a human-readable format, providing functionality similar to [snmptranslate](http://www.net-snmp.org/wiki/index.php/TUT:snmptranslate).

Features
--------

* Improved Windows support over original net-snmp gem
* Supports SNMP versions 1, 2c, and 3
* Supports both synchronous and asynchronous calls
* Supports sending of snmpv1 traps and snmpv2 traps/informs using TrapSession
* Integrates well with eventmachine, or can be used standalone.
* In Ruby 1.9, uses fibers behind the scenes to emulate synchronous calls asynchronously
* MIB support
* Convenience methods such as session.walk, session.get_columns, and session.table
* SNMP Agent support
* Trap handler support

Notes
-----

- TrapHandler & Agent support doesn't work on default Windows build of net-snmp libraries, due to certain functions not being exported in the dll.
  + There is a [net-snmp-clone](https://github.com/jbreeden/net-snmp-clone) repo with the fixes made if you'd like to build this from source.
  + Or, you can try my [pre-built DLL](https://github.com/jbreeden/net-snmp-clone/raw/master/win32/bin/release/netsnmp.dll) from the same repo.
  + I've submitted this as a [feature request](https://sourceforge.net/p/net-snmp/feature-requests/181/) & patch to the net-snmp team. If it works for you, please go make a comment indicating that on the feature request to help it get pulled into the core library.
- Original gem was using a different comment format... I've opted for markdown. The generated rdocs are probably garbage.
  + The [wiki](https://github.com/jbreeden/net-snmp2/wiki) has the best documentation for now.
  + All the specs are passing, so that's another good place to go for information.
  + There is also the built-in net-snmp2 program you can run. This is an interactive Pry shell that is very useful for digging around the code and getting a feel for how to do things.
