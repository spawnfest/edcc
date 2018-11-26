# edcc
edcc is an Elixir based approach to distributed compilation.
With this proof of concept we aim to distribute the compilation of `C` files in such a way that dependecy detection and their compilation are done in remote.
After that the client node will link the object files `(.o)` in an executable called `main`.

> Note that in order to launch the program we use `Edcc` (with a capital letter) instead of `edcc`, following Elixir naming convention.

## Prerequisites
To be able to use `edcc` it is assumed that your computer has at least:

 - Elixir
 - gcc

## How to use it
The `Edcc` module has two public functions:

 - init/2 
 - help/0

The function *init/2* receives as parameters a path (`String`), where the files to compile are to be found, and a `node list`, which will be used to distribute the files.

    iex> Edcc.init("project",[:foo@bar, :bar@foo])

The *help/0* function has no parameters and prints out an example of the aforementioned call, *init/2*, followed by `:ok`.

    iex> Edcc.help
    Edcc.init("path_to_dir", [:node_1@Node_1, :node_2@Node_2, ..., :node_n@Node_n])
    :ok
    
## Example
An example of the program in use:

 - A file *foo.c*, which has the following content:
    ```
    #include <stdio.h>
    #include "bar.h"
    
    int main() {
        helloWorld();        
        return 0;
    }            
 - A file *bar.c*, which has the following content:
    ```
    #include "bar.h"

    void helloWorld() {
        printf("Hello, World!\n");
    }
 - A file *bar.h*, which has the following content:
    ```
    #include <stdio.h>

    void helloWorld();
All three files can be found on the *examples* folder.
<pre>
    examples
    ├── bar.c
    ├── bar.h
    └── foo.c
</pre>
> This folder is inside the project to make it easier to test it.

Assuming that the following nodes *node_1@Node_1* and *node_2@Node_2* are reachable and already identified as mentioned:

 - Start a new Iex session on the project folder *edcc*:

    `iex --sname me@mee -S mix`

 - Invoke *init/2*, with the earlier mentioned parameters:

    `iex> Edcc.init("examples",[:node_1@Node_1,:node_2@Node_2])`

If everything went according, it should return the following tuple:
    `{:ok, :files_linked_successfully}`

A *main* executable can now be found on the *examples* folder, as a result of the compilation.
 
## Assumptions:

 - We assume that there is only a file to link.
 - We assume that the dependencies can be resolved with the files existing on the directory.
 - We assume that the connected nodes are executed on machines with the same architecture/OS, in other words, they wont yield errors at linking time.

## Exceptions
Nonetheless, `edcc` detects certain irregularities (although not as many as we would want).
 - If none of the nodes is reachable, `NotFoundException` will be raised with the following message: `"No nodes were found."`.
 - If during the execution a call to *gcc* yields an error, `RuntimeError` will be raised with the following message: `"Could not compile the file #filename (exit code: #code)."`.

## To-Do:
- Add some unit tests.
- Differentiate between architectures to allow more specific work done on the nodes.