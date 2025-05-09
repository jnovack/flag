[![Github](https://badgen.net/badge/jnovack/flag/purple?icon=github)](https://github.com/jnovack/flag)
[![Build Status](https://github.com/jnovack/flag/workflows/main/badge.svg)](https://github.com/jnovack/flag/actions)
[![GoDoc](https://godoc.org/github.com/jnovack/flag?status.svg)](http://godoc.org/github.com/jnovack/flag)
[![Go Report](https://goreportcard.com/badge/github.com/jnovack/flag)](https://goreportcard.com/report/github.com/jnovack/flag)
[![codecov](https://codecov.io/gh/jnovack/flag/branch/master/graph/badge.svg)](https://codecov.io/gh/jnovack/flag)

# jnovack/flag

**jnovack/flag** is a drop in replacement for Go's flag package with the
addition to parse files and environment variables. If you support the
[twelve-factor app methodology][], Flag complies with the third factor;
"Store config in the environment".

[twelve-factor app methodology]: http://12factor.net

An example using a command-line parameter:

```go
$ cat > gopher.go
    package main

    import (
        "fmt"
        "github.com/jnovack/flag"
    )

    func main() {
        var age int
    flag.IntVar(&age, "age", 0, "age of gopher")
    flag.Parse()
    fmt.Print("age:", age)
    }
$ go run gopher.go -age 1
age: 1
```

Same code but using an environment variable:

```go
$ export AGE=2
$ go run gopher.go
age: 2
```

Same code but using a configuration file:

```go
$ cat > gopher.conf
age 3

$ go run gopher.go -config gopher.conf
age: 3
```

The following table shows how flags are translated to environment variables
and configuration files:

| Type   | Flag          | Environment  | File         |
| ------ | :------------ |:------------ |:------------ |
| int    | -age 2        | AGE=2        | age 2        |
| bool   | -female       | FEMALE=true  | female true  |
| float  | -length 175.5 | LENGTH=175.5 | length 175.5 |
| string | -name Gloria  | NAME=Gloria  | name Gloria  |
| string | -last-name Estefan  | LAST_NAME=Estefan  | last-name Estefan  |

Note that dashes in variable names are equivalent to underscores when using
environment variables.

This package is a port of Go's [flag][] package from the standard library with
the addition of two functions `ParseEnv` and `ParseFile`.

[flag]: http://golang.org/src/pkg/flag

## Goals

- Compatability with the original `flag` package
- Support the [twelve-factor app methodology][]
- Uniform user experience between the three input methods

### Why

Why not use one of the many INI, JSON or YAML parsers?

I find it best practice to have simple configuration options to control the
behaviour of an applications when it starts up. Use basic types like ints,
floats and strings for configuration options and store more complex data
structures in the "datastore" layer.

## Usage

It's intended for projects which require a simple configuration made available
through command-line flags, configuration files and shell environments. It is
similar to the original `flag` package.

Example:

```go
import "github.com/jnovack/flag"

flag.String(flag.DefaultConfigFlagname, "", "path to config file")
flag.Int("age", 24, "help message for age")

flag.Parse()
```

Order of precedence:

1. Command line options
2. Environment variables
3. Configuration file
4. Default values

### Parsing Configuration Files

Create a configuration file:

```go
$ cat > ./gopher.conf
# empty newlines and lines beginning with a "#" character are ignored.
name bob

# keys and values can also be separated by the "=" character
age=20

# booleans can be empty, set with 0, 1, true, false, etc
hacker
```

Add a "config" flag:

```go
flag.String(flag.DefaultConfigFlagname, "", "path to config file")
```

Run the command:

```go
go run ./gopher.go -config ./gopher.conf
```

The default flag name for the configuration file is "config" and can be
changed by setting `flag.DefaultConfigFlagname`:

```go
flag.DefaultConfigFlagname = "conf"
flag.Parse()
```

### Parsing Environment Variables

Environment variables are parsed 1-on-1 with defined flags:

```go
$ export AGE=44
$ go run ./gopher.go
age=44
```

You can also parse prefixed environment variables by setting a prefix name
when creating a new empty flag set:

```go
fs := flag.NewFlagSetWithEnvPrefix(os.Args[0], "GO", 0)
fs.Int("age", 24, "help message for age")
fs.Parse(os.Args[1:])
...
$ go export GO_AGE=33
$ go run ./gopher.go
age=33
```

For more examples see the [examples][] directory in the project repository.

[examples]: https://github.com/jnovack/flag/tree/master/examples

That's it.

## Credits

**jnovack/flag** would not be possible without
[@namsral](https://github.com/namsral/flag/) and his work to start this
project.  To be fair, all I have done is kept this package in step with
the current released versions of golang.
