# Automate

Automation script for JAMF packaging workflow

## Quick Links

* [Scripts Repo](https://github.com/duke-jamf/scripts)
* [Definitions Repo](https://github.com/duke-jamf/definitions)

## Usage

This is an example of an automated workflow using [JAMF Scripts](https://github.com/duke-jamf/scripts)
and [JAMF Definitions](https://github.com/duke-jamf/definitions) to generate `.pkg` files
for new and updated definitions.

> *Note: See additional documentation at the two repos above*

## Input

**Automate** contains one script: **src/automate**. It will search for **scripts** and
**definitions** directories in the same directory as this script. These should be sourced
from the repo above (e.g. **{automate_repo}/src/scripts/src/build** should exist). If it
does not locate either of these it will clone fresh copies, so it is acceptable to run
`automate` directly from a cloned repo if you want to use all the default
[Duke JAMF Definitions](https://github.com/duke-jamf/definitions).

## Output

Running `automate` will create the **build** directory in your current working directory.
This new directory will contain all the packages generated during the build process for
each definition, as well as **results.log**, a simple summary of the result for each
definition in the format `{result}: {definition|package}`.
