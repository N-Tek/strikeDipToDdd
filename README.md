# strikeDipToDdd

Bash script that converts a planar measurement in strike-dip format to dip-dip direction
format

## Contents

* [Target User](#target-user)
* [Building and Installation](#building-and-installation)
  - [Requirements](#requirements)
  - [Building](#building)
  - [Installation](#installation)
* [Removal](#removal)
* [Usage](#usage)
* [Support](#support)
* [Roadmap](#roadmap)
* [Code of Conduct](#code-of-conduct)
* [Contributing](#contributing)
* [License](#license)
* [Project Status](#project-status)

## Target User

Engineering geologists, structural geologists, geotechnical engineers having 
planar measurements in strike-dip format that should be converted to the ones
in dip-dip direction format.

## Building and Installation

Don't have to build anything, related bash shell script can be used by copying
the script file in your system, setting file permissions and executing with
required command-line arguments.

### Requirements

    Operating System: Linux

    Distro          : Any

    Shell           : bash          ≥ 4.3.48

    Other           : All numerical measurements must be integer values
    
### Building

Doesn't require a building process, can be used directly.

### Installation

Doesn't require an installation process, can be directly copied anywhere.

## Removal

Can be removed by directly deleting the related script file.

## Usage

`Usage: ./strikeDipToDdd [-r] [-d DELIM] [-h] ((-a | -b | -A | -B)  (MEASUREMENT | MEASUREMENT_FILE))...`  
`-a`    input in    RHR-azimuth format,  dip direction 90⁰ clockwise from strike  
`-b`    input in    RHR-bearing format,  dip direction 90⁰ clockwise from strike  
`-A`    input in UK-RHR-azimuth format,  dip direction 90⁰ counter-clockwise from strike  
`-B`    input in UK-RHR-bearing format,  dip direction 90⁰ counter-clockwise from strike  
`-d DELIM`   use DELIM instead of space as the delimiter of output values  
`-r`    print out number of converted and invalid measurements  
`-h`    Display help

where 

- an example of `MEASUREMENT`  
for option `-a` is `045/20SE`,  
for option `-b` is `N45E/20SE`,  
for option `-A` is `045/20NW`,  
for option `-B` is `N45E/20NW` 
    
- a `MEASUREMENT_FILE` is a list of `MEASUREMENT`s all having a common format, each written in a single line
(measurements having different formats are not allowed in a `MEASUREMENT_FILE`)
	   
- any `MEASUREMENT` value that DOESN'T conform to the related format will be counted as `Invalid` or  
   if located in a `MEASUREMENT_FILE` will be counted as `Invalid Infile`
 
***Example:***  
*$ ./strikeDipToDdd -r -d ',' -a 045/20SE -b N45E/20SE -A O45/20NW -B N45E/20NW  
20/135,  
20/135,  
20/315,  
20/315,  
Converted Infile : 0  
Invalid   Infile : 0  
Converted        : 4  
Invalid          : 4*
 
## Support

All types of constructive criticisms and contributions are welcome, and I'll
try my best for solving your problems related with the scripts and patches
presented in this repo as an engineering geologist, a self-learner and a guy
who enjoys coding.

For further info please check [SUPPORT.md](./SUPPORT.md).

## Roadmap

Essentially I've created this repo to solve my problem at the first place and
I've to admit I really have no idea in the beginning but with time I've learned
lots of stuff from the guys and the gals like myself who has tried to solve their
problems and decided to share their findings with other individuals who might
face similar problems. Remembering all of them individually at this point is
a bit hard for me so I've created this repo to show my graditude.

Additional ideas related with the future are welcomed.

## Code of Conduct

[Contributor Covenant version 2.1][CoC] is the effective code of conduct for this
project.

For further info please check [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md).

## Contributing

Please check [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

Software presented in this repository is licensed with GPLv3.

For further info please check [COPYING](./COPYING).

## Project Status

This project is actively maintained by Necib ÇAPAR.

[CoC]: https://www.contributor-covenant.org/version/2/1/code_of_conduct.html
