SkinIO
========

An object (read struct) oriented maxscript lib to deal with 3dsmax's skin input/ouput operations using efficient paradigms.

Paradigms
--------

Because SkinIO is meant to be integrated in pipelines that are constantly moving, it uses some simples but powerful paradigms:
  - Every operation is started from a request object
  - Implicit returns are always used when possible


Documentation
--------

SkinIO is documented using NaturalDocs. Either read the source files or clone the git and check documentation/index.html

  - SkinIOHelpers.ms 
  - SkinIOModules.ms
  - SkinIORequests.ms
  - SkinIOReturn.ms
