Protected type definitions used in the VVC Framework, defined in ti_protected_types_pkg.vhd

.. _t_prot_vvc_list:

t_prot_vvc_list
----------------------------------------------------------------------------------------------------------------------------------

Protected type to gather VVC's in a list.


add()
^^^^^

Adds a VVC to the protected VVC list.


.. code-block::

    add(name, instance, [channel])


+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | name               | in     | string                       | VVC's name defined in vvc_methods_pkg as C_VVC_NAME     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | instance           | in     | integer                      | Instance number of the VVC                              |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| constant | channel            | in     | t_channel                    | The VVC channel of the VVC instance                     |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+

.. code-block::

    -- Examples:
    variable v_vvc_list : t_prot_vvc_list;
    v_vvc_list.add("SBI_VVC", 1);
    v_vvc_list.add("UART_VVC", ALL_INSTANCES, ALL_CHANNELS);



clear_list()
^^^^^^^^^^^^

Clear all entries from the protected VVC list.

.. code-block::

    clear_list(VOID)


+----------+--------------------+--------+------------------------------+---------------------------------------------------------+
| Object   | Name               | Dir.   | Type                         | Description                                             |
+==========+====================+========+==============================+=========================================================+
| constant | VOID               | in     | t_void                       | A dummy parameter for easier reading syntax             |
+----------+--------------------+--------+------------------------------+---------------------------------------------------------+


.. code-block::

    -- Examples:
    v_vvc_list.clear_list(VOID);
