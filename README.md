# Linux development environment for SMW romhacks

This repository provides configuration for building an SMW romhack on Linux.
It contains container definitions for a number of tools, as well as a
Makefile which can use those tools to build a full romhack from the provided
configuration.

## Dependencies

* `make`
* `podman` or `docker`

## Tools

* Lunar Magic
* Floating IPS
* Asar
* UberASM
* PIXI
* GPS
* AddmusicK

## Configuration

Overall build configuration can be found in Make.config:

* `NAME`: The name to use for the generated ROM file.
* `DOCKER`: The command to use for building and running the containers.
  Useful values include `podman` or `docker` (or potentially `sudo podman` or
  `sudo docker` if you have not configured rootless access).
* `*_URL`: The location to download the source code for the various tools.

Configuration for the individual tools should mostly work as normal:

* The original unmodified SMW ROM should be placed at `baserom/smw.smc`. If
  you wish to use a baserom patch, you should place it at
  `baserom/baserom.bps`.
* Levels created in Lunar Magic should be saved individually to the `levels`
  directory. Any filenames can be used.
* Map16 edits should be exported individually to the `map16` directory. Files
  should be named like `map16/105.map16` where 105 is the level number to
  apply the edits to.
* Any ASM files to be applied by Asar should be put in the `asar` directory.
* UberASM files should be placed in their normal directories (`gamemode`,
  `level`, etc). Files which are shipped with UberASM itself (the `asm`
  directory, etc) do not need to be included here. Use `list-uberasm.txt`
  instead of `list.txt` for the UberASM configuration. The `rom` option can
  be left out, since it will be added automatically by the build process.
* PIXI files should be placed in their normal directories (`sprites`,
  `shooters`, etc). Files which are shipped with UberASM itself (the `asm`
  directory, etc) do not need to be included here. Use `list-pixi.txt`
  instead of `list.txt` for the PIXI configuration.
* GPS files should be placed in their normal directories (`blocks`, etc).
  Files which are shipped with GPS itself (the `routines` directory, etc) do
  not need to be included here. Use `list-gps.txt` instead of `list.txt` for
  the GPS configuration.
* Music files should be placed in their normal directories (`music`,
  `samples`, etc). Files which are shipped with AddmusicK itself (the `asm`
  directory, etc) do not need to be included here. Use `list-addmusick.txt`
  instead of `Addmusic_list.txt` for the AddmusicK configuration. Only
  configuration for new music should go in this file, it will be
  automatically combined with the base game music configuration shipped with
  AddmusicK. 

## Building

* `make rom`: Generates the ROM itself. (Default if `make` is run with no
  arguments)
* `make run`: Generates the ROM if necessary, and then runs it in Snes9x, if
  installed.
* `make patch`: Generates a patch which can be applied to the original SMW
  ROM to create the hack (for distribution).
* `make clean`: Removes all generated files.

## Known issues

* Overworld edits are not yet supported - the build process will insert the
  levels into the ROM, but overworld changes will have to be made afterward
  separately.
