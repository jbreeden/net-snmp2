Notes
-----

- For the tests to run, you must first run `ruby spec/test_agent.r`
- You also need to run an external trap receiver
  + I'm currently using MIBBrowser's builtin receiver

Latest Results
--------------

Generated with `rspec -f d -o spec/spec.txt --no-color`

```
async
  version 1
    getnext should work
    get
      retrieves scalar values
      when a timeout occurrs
        calls back with :timeout when a timeout occurrs
  version 2
    get should work
    getnext should work

em
  should work in event_machine

snmp errors
  should rescue a timeout error
  should rescue timeout error in a fiber

in fiber
  get should work in a fiber with synchronous calling style
  getnext
  should get using snmpv3 (PENDING: No reason given)

Net::SNMP::MIB
  ::translate
    translates OIDs to variable names including instance indexes
    translates variable names to OIDs including instance indexes
  ::[]
    can retrieve MIB nodes by variable name
    can retrieve MIB nodes by numeric oid

Net::SNMP::MIB::Node
  ::get_node
    retrieves MIB nodes by variable name
    retrieves MIB nodes by numeric oid
  #parent
    links to the parent node
  #children
    contains Node objects for all child nodes
  #siblings
    contains an array of sibling nodes
  #oid
    is an OID object for the node

Net::SNMP::OID
  should instantiate valid oid with numeric
  should instantiate valid oid with string
  should to_s correctly

synchronous calls
  version 1
    get should succeed
    multiple calls within session should succeed
    get should succeed with multiple oids
    set should succeed
    getnext should succeed
    getbulk should succeed
    getbulk should succeed with multiple oids
    rasises an when a non-existant MIB variable is requested
    get_table should work
    walk should work
    walk should work with multiple oids
    get_columns should work
    get a value with oid type should work

in a thread
  should get an oid asynchronously in a thread

Net::SNMP::TrapSession
  should send a v1 trap
  should send v2 trap
  should send a v2 inform

Net::SNMP::Utility
  should compare oids

Net::SNMP::Wrapper
  wrapper should snmpget synchronously
  wrapper should snmpget asynchronously

Pending:
  in fiber should get using snmpv3
    # No reason given
    # ./spec/fiber_spec.rb:32

Finished in 29.01 seconds (files took 0.34884 seconds to load)
44 examples, 0 failures, 1 pending
```
