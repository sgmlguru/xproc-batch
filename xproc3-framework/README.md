# README

This contains a very basic XProc 3.0 editor environment, with XProc pipeline validation using an XProc 3.0 Relax NG grammar compiled on 2022-06-21.


## Prerequisites

This environment requires the following:

* A recent (24.x) version of oXygen XML Editor
* An XProc 3.0 processor such as [MorganaXProc-III](https://www.xml-project.com/morganaxproc-iii/), if you want to actually run your pipelines rather than keeping them a theoretical exercise


## Setup

Double-click on the `xproc3.xpr` project file. It initiates a context-aware XProc 3.0 editor environment *for files using the file suffix `.xpl`*.

There are two "templates", one for `declare-step` and another for `library`.


## Limitations

* You cannot edit XProc 1.0 pipelines while the XProc 3.0 framework is active
* Your 3.0 pipelines need to use the `.xpl` file suffix to get content completion
* There is currently no built-in scenario to run XProc 3.0 pipelines from within the editor


## What If I Find a Bug?

Drop me an [email](mailto:ari.nordstrom@gmail.com). Or check the [available resources](https://xproc.org/specifications.html).
