History
=======

Version 0.3.1
-------------

- Internal changes
  + Adding source_address & source_port to message object
    * Changes the callback signature for Listener#on_message
  + Adding Message#respond method
    * Used for creating a one-off session for responding to a message
      and sending a single pdu over it. (Used in TrapHandler & Agent)

Version 0.3.0
-------------

- First gem release as net-snmp2
