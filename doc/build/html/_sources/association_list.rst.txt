##################################################################################################################################
UVVM Association List
##################################################################################################################################
An association list maps values to keys, and is a simple implementation of the *associative array* data structure (also known as
*dictionary* in some programming languages). By adding a key and a value to the list, you create an association (mapping) between
the value and the key. One of the advantages this has over using a regular array is that values can be retrieved by using
meaningful keys instead of arbitrary indices. However, this means that the keys must be unique. Another advantage of the
association list is that it is dynamic. The list size is automatically incremented when a new key-value pair is added, and it is
automatically decremented when the *delete* function is called with a valid key.

Common use cases for the association list (associative array) are to represent structured data, or when working with sparse data.
An example useful for verification is to model memories. If there is no need to model the entire address space of a memory, an
association list (associative array) can be used to store data only for the addresses used. This will save computer memory compared
to modelling the entire memory using a regular array. However, It should be noted that the association list is implemented as a linked
list, which means that the time needed to search the list for a given key increases with the list size. For this reason it is
recommended to keep the key space is small.

The association list is generic and both key and value can be of any type. However, keys are recommended to be simple types like
integers and strings. The list is implemented as a linked list, and functions that operate on the list will generally do a linear
search for the key to find the correct list item. For efficiency, the list maintains a reference to the last list item searched for,
appended, or updated. This means that multiple consecutive operations on the same list item will not result in
new searches for the key.

.. note::

   Because of performance limitations it is recommended to keep the key space small.

**********************************************************************************************************************************
Generics
**********************************************************************************************************************************

+---------------+--------+------------------------+-------------------------------+
| Name          | Type   | Default                | Description                   |
+===============+========+========================+===============================+
| GC_SCOPE      | string | "association_list_pkg" | Scope used in reporting       |
+---------------+--------+------------------------+-------------------------------+
| GC_KEY_TYPE   | type   | <none>                 | The type of the key           |
+---------------+--------+------------------------+-------------------------------+
| GC_VALUE_TYPE | type   | <none>                 | The type of the value         |
+---------------+--------+------------------------+-------------------------------+

**********************************************************************************************************************************
Types
**********************************************************************************************************************************

t_association_list_status
----------------------------------------------------------------------------------------------------------------------------------
Enumeration type used as return value to indicate success or failure. Please see
:ref:`types_pkg.t_association_list_status<t_association_list_status>`.

This is an enumeration type that is intended to be used as return value from some of the functions in the association list data
structure. Possible values are ASSOCIATION_LIST_SUCCESS and ASSOCIATION_LIST_FAILURE.

t_association_list
----------------------------------------------------------------------------------------------------------------------------------
This is a generic association list data structure implemented using a protected type.

**********************************************************************************************************************************
Declaration
**********************************************************************************************************************************

.. code-block::

   -- Package declaration example
   package string_association_list_pkg is new uvvm_util.association_list_pkg
      generic map( GC_SCOPE => "string_association_list_pkg",
                   GC_KEY_TYPE => string,
                   GC_VALUE_TYPE => integer);

.. code-block::

   -- association list declaration example
   use work.string_association_list_pkg.all;
   variable v_association_list : t_association_list;

**********************************************************************************************************************************
Methods
**********************************************************************************************************************************

append()
----------------------------------------------------------------------------------------------------------------------------------
This function appends the given key-value pair to the end of the list if the key does not already exist. ::

   t_association_list_status := append(key, value)

.. code-block::

   -- Example:
   v_return_value := association_list.append("my_key", 42);


key_in_list()
----------------------------------------------------------------------------------------------------------------------------------
This function checks if the given key is in the list. ::

   boolean := key_in_list(key)

.. code-block::

   -- Example:
   v_return_value := association_list.key_in_list("my_key");


delete()
----------------------------------------------------------------------------------------------------------------------------------
This function deletes the list item with the given key. ::

   t_association_list_status := delete(key)

.. code-block::
   
   -- Example:
   v_return_value := association_list.delete("my_key");

length()
----------------------------------------------------------------------------------------------------------------------------------
This function returns the length of the list. ::

   natural := length(VOID)

.. code-block::

   -- Example:
   v_length := association_list.length(VOID);


get()
----------------------------------------------------------------------------------------------------------------------------------
This function gets the value associated with the given key. ::

   GC_VALUE_TYPE := get(key)

.. code-block::

   -- Example:
   v_value := association_list.get("my_key");

.. note::

   This function assumes that the given key is in the list. Calling this function with a key that is not in the list will result
   in a failure.

set()
----------------------------------------------------------------------------------------------------------------------------------
This function updates the value associated with the given key. ::

   t_association_list_status := set(key, value)

.. code-block::

   -- Example:
   v_return_value := association_list.set("my_key", 100);


clear()
----------------------------------------------------------------------------------------------------------------------------------
This function will delete all list items. ::

   t_association_list_status := clear(VOID)

.. code-block::

   -- Example:
   v_return_value := association_list.clear(VOID);


.. include:: rst_snippets/ip_disclaimer.rst
